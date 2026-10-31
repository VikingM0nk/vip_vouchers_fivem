const app = document.getElementById('app');
const menuTitle = document.getElementById('menu-title');
const categoriesEl = document.getElementById('categories');
const entriesEl = document.getElementById('entries');
const categoryTitle = document.getElementById('category-title');
const categorySubtitle = document.getElementById('category-subtitle');
const closeBtn = document.getElementById('close-btn');
const pickModal = document.getElementById('pick-modal');
const pickTitle = document.getElementById('pick-title');
const pickSubtitle = document.getElementById('pick-subtitle');
const pickChoicesEl = document.getElementById('pick-choices');
const pickCounter = document.getElementById('pick-counter');
const pickConfirmBtn = document.getElementById('pick-confirm-btn');
const pickCloseBtn = document.getElementById('pick-close-btn');
const instructionsPanel = document.getElementById('instructions-panel');
const instructionsTitle = document.getElementById('instructions-title');
const instructionsSteps = document.getElementById('instructions-steps');
const instructionsNote = document.getElementById('instructions-note');
const instructionsDiscordBtn = document.getElementById('instructions-discord-btn');
const instructionsToggle = document.getElementById('instructions-toggle');
const instructionsBody = document.getElementById('instructions-body');

const resourceName =
  typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'vip_vouchers';

let state = {
  categories: [],
  products: [],
  paymentProviders: [],
  storeEnabled: false,
  activeCategoryId: null,
  redeemed: new Set(),
  pickContext: null,
  pickSelected: new Set(),
  instructionsCollapsed: false,
};

function post(name, data = {}) {
  return fetch(`https://${resourceName}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data),
  });
}

function openPurchaseUrl(url, roleKey, providerId) {
  if (!url) return;
  post('purchase', { url, roleKey, providerId });
  if (typeof window.invokeNative === 'function') {
    window.invokeNative('openUrl', url);
  } else {
    window.open(url, '_blank');
  }
}

function iconLabel(icon) {
  if (!icon) return 'VIP';
  return icon.slice(0, 3).toUpperCase();
}

function setTheme(data) {
  if (data.accentGold) {
    document.documentElement.style.setProperty('--gold', data.accentGold);
  }
  if (data.accentPurple) {
    document.documentElement.style.setProperty('--purple', data.accentPurple);
  }
}

function isConfiguredUrl(url) {
  if (!url || typeof url !== 'string') return false;
  const blocked = ['PUT_', 'yourserver', 'yourstore', 'discord.gg/your'];
  return !blocked.some((token) => url.includes(token));
}

function renderInstructions(instructions) {
  if (!instructions || instructions.enabled === false) {
    instructionsPanel.classList.add('hidden');
    return;
  }

  instructionsPanel.classList.remove('hidden');
  instructionsTitle.textContent = instructions.title || 'How to Purchase & Redeem';
  instructionsSteps.innerHTML = '';

  (instructions.steps || []).forEach((step) => {
    const item = document.createElement('li');
    item.textContent = step;
    instructionsSteps.appendChild(item);
  });

  if (instructions.note) {
    instructionsNote.textContent = instructions.note;
    instructionsNote.classList.remove('hidden');
  } else {
    instructionsNote.textContent = '';
    instructionsNote.classList.add('hidden');
  }

  if (isConfiguredUrl(instructions.discordInvite)) {
    instructionsDiscordBtn.textContent = instructions.discordLabel || 'Open Discord';
    instructionsDiscordBtn.classList.remove('hidden');
    instructionsDiscordBtn.onclick = () => openPurchaseUrl(instructions.discordInvite, null, 'discord');
  } else {
    instructionsDiscordBtn.classList.add('hidden');
    instructionsDiscordBtn.onclick = null;
  }

  instructionsPanel.classList.toggle('collapsed', state.instructionsCollapsed);
  instructionsToggle.textContent = state.instructionsCollapsed ? '+' : '−';
}

instructionsToggle.addEventListener('click', () => {
  state.instructionsCollapsed = !state.instructionsCollapsed;
  instructionsPanel.classList.toggle('collapsed', state.instructionsCollapsed);
  instructionsToggle.textContent = state.instructionsCollapsed ? '+' : '−';
});

function renderBadges(badges) {
  if (!badges || badges.length === 0) return '';
  return badges
    .map(
      (badge) =>
        `<span class="tier-badge" style="${badge.color ? `--badge-color:${badge.color}` : ''}">${badge.label}</span>`
    )
    .join('');
}

function createPurchaseActions(purchaseLinks, roleKey, price) {
  const wrapper = document.createElement('div');
  wrapper.className = 'purchase-actions';

  const providers = state.paymentProviders.filter(
    (provider) => purchaseLinks && purchaseLinks[provider.id]
  );

  if (providers.length === 0) {
    const fallback = document.createElement('button');
    fallback.className = 'entry-action purchase-action';
    fallback.textContent = price ? `Purchase ${price}` : 'Purchase';
    fallback.disabled = true;
    wrapper.appendChild(fallback);
    return wrapper;
  }

  providers.forEach((provider) => {
    const button = document.createElement('button');
    button.className = `entry-action purchase-action provider-${provider.id}`;
    button.textContent = provider.label;
    button.addEventListener('click', () =>
      openPurchaseUrl(purchaseLinks[provider.id], roleKey, provider.id)
    );
    wrapper.appendChild(button);
  });

  return wrapper;
}

function renderCategories() {
  categoriesEl.innerHTML = '';

  if (state.storeEnabled && state.products.length > 0) {
    const storeBtn = document.createElement('button');
    storeBtn.className = 'category-btn';
    storeBtn.dataset.categoryId = '__store__';
    if (state.activeCategoryId === '__store__') storeBtn.classList.add('active');
    storeBtn.innerHTML = `
      <span class="category-icon store-icon">$</span>
      <span>Store</span>
    `;
    storeBtn.addEventListener('click', () => {
      state.activeCategoryId = '__store__';
      renderCategories();
      renderEntries();
    });
    categoriesEl.appendChild(storeBtn);
  }

  state.categories.forEach((category, index) => {
    const button = document.createElement('button');
    button.className = 'category-btn';
    button.dataset.categoryId = category.id;

    if (
      category.id === state.activeCategoryId ||
      (!state.activeCategoryId && index === 0 && !state.storeEnabled)
    ) {
      button.classList.add('active');
      if (!state.activeCategoryId && index === 0 && !state.storeEnabled) {
        state.activeCategoryId = category.id;
      }
    }

    button.innerHTML = `
      <span class="category-icon">${iconLabel(category.icon)}</span>
      <span>${category.label}</span>
    `;

    button.addEventListener('click', () => {
      state.activeCategoryId = category.id;
      renderCategories();
      renderEntries();
    });

    categoriesEl.appendChild(button);
  });
}

function renderStoreProducts() {
  categoryTitle.textContent = 'Store';
  categorySubtitle.textContent = 'Purchase via Squaresite or PayPal to unlock vouchers in-game.';

  if (!state.products.length) {
    entriesEl.innerHTML = '<div class="empty-state">No store products configured.</div>';
    return;
  }

  entriesEl.innerHTML = '';
  state.products.forEach((product) => {
    const card = document.createElement('article');
    card.className = 'entry-card store-card';
    if (product.owned) card.classList.add('owned');

    card.innerHTML = `
      <div class="card-top">
        ${renderBadges([{ label: product.badge, color: product.color }])}
        ${product.owned ? '<span class="owned-pill">Unlocked</span>' : '<span class="locked-pill">Locked</span>'}
      </div>
      <h3>${product.label}</h3>
      <p>${product.description || ''}</p>
      ${product.price ? `<p class="price-tag">${product.price}</p>` : ''}
    `;

    if (product.owned) {
      const ownedBtn = document.createElement('button');
      ownedBtn.className = 'entry-action owned-action';
      ownedBtn.textContent = 'Owned';
      ownedBtn.disabled = true;
      card.appendChild(ownedBtn);
    } else {
      card.appendChild(createPurchaseActions(product.purchaseLinks, product.roleKey, product.price));
    }

    entriesEl.appendChild(card);
  });
}

function openPickModal(category, entry) {
  state.pickContext = { categoryId: category.id, entryId: entry.id, pickCount: entry.pickCount || 3 };
  state.pickSelected = new Set();

  pickTitle.textContent = entry.label;
  pickSubtitle.textContent = entry.description || `Select exactly ${entry.pickCount || 3} rewards.`;
  pickChoicesEl.innerHTML = '';

  (entry.choices || []).forEach((choice) => {
    const btn = document.createElement('button');
    btn.className = 'pick-choice';
    btn.dataset.choiceId = choice.id;
    btn.innerHTML = `<strong>${choice.label}</strong>`;
    btn.addEventListener('click', () => togglePickChoice(choice.id, btn));
    pickChoicesEl.appendChild(btn);
  });

  updatePickCounter();
  pickModal.classList.remove('hidden');
}

function closePickModal() {
  pickModal.classList.add('hidden');
  state.pickContext = null;
  state.pickSelected = new Set();
}

function togglePickChoice(choiceId, button) {
  const pickCount = state.pickContext?.pickCount || 3;

  if (state.pickSelected.has(choiceId)) {
    state.pickSelected.delete(choiceId);
    button.classList.remove('selected');
  } else if (state.pickSelected.size < pickCount) {
    state.pickSelected.add(choiceId);
    button.classList.add('selected');
  }

  updatePickCounter();
}

function updatePickCounter() {
  const pickCount = state.pickContext?.pickCount || 3;
  pickCounter.textContent = `${state.pickSelected.size} / ${pickCount} selected`;
  pickConfirmBtn.disabled = state.pickSelected.size !== pickCount;
}

function renderEntries() {
  entriesEl.innerHTML = '';

  if (state.activeCategoryId === '__store__') {
    renderStoreProducts();
    return;
  }

  const category = state.categories.find((item) => item.id === state.activeCategoryId);

  if (!category) {
    categoryTitle.textContent = 'No categories';
    categorySubtitle.textContent = 'Browse the store or purchase a tier to unlock vouchers.';
    entriesEl.innerHTML = '<div class="empty-state">Nothing to show yet.</div>';
    return;
  }

  categoryTitle.textContent = category.label;
  categorySubtitle.textContent = 'Redeem unlocked vouchers or purchase locked tiers.';

  if (!category.entries || category.entries.length === 0) {
    entriesEl.innerHTML = '<div class="empty-state">No vouchers in this category.</div>';
    return;
  }

  category.entries.forEach((entry) => {
    const card = document.createElement('article');
    card.className = 'entry-card';
    card.dataset.entryId = entry.id;

    if (entry.locked) card.classList.add('locked');
    if (state.redeemed.has(entry.id)) card.classList.add('redeemed');

    card.innerHTML = `
      <div class="card-top">
        ${renderBadges(entry.badges)}
        ${
          entry.locked
            ? '<span class="locked-pill">Locked</span>'
            : '<span class="owned-pill">Unlocked</span>'
        }
      </div>
      <h3>${entry.label}</h3>
      <p>${entry.description || ''}</p>
    `;

    if (state.redeemed.has(entry.id)) {
      const action = document.createElement('button');
      action.className = 'entry-action';
      action.textContent = 'Redeemed';
      action.disabled = true;
      card.appendChild(action);
    } else if (entry.locked) {
      card.appendChild(createPurchaseActions(entry.purchaseLinks));
    } else if (entry.action === 'pick_multiple') {
      const action = document.createElement('button');
      action.className = 'entry-action';
      action.textContent = 'Choose Rewards';
      action.addEventListener('click', () => openPickModal(category, entry));
      card.appendChild(action);
    } else {
      const action = document.createElement('button');
      action.className = 'entry-action';
      action.textContent = 'Redeem';
      action.addEventListener('click', () => {
        action.disabled = true;
        action.textContent = 'Redeeming...';
        post('redeem', { categoryId: category.id, entryId: entry.id });
      });
      card.appendChild(action);
    }

    entriesEl.appendChild(card);
  });
}

function openMenu(data) {
  state.categories = data.categories || [];
  state.products = data.products || [];
  state.paymentProviders = data.paymentProviders || [];
  state.storeEnabled = data.storeEnabled === true;
  state.activeCategoryId = state.storeEnabled ? '__store__' : state.categories[0]?.id || null;
  state.redeemed = new Set();

  menuTitle.textContent = data.title || 'VIP Vouchers';
  setTheme(data);
  renderInstructions(data.instructions);

  renderCategories();
  renderEntries();
  app.classList.remove('hidden');
}

function closeMenu() {
  closePickModal();
  app.classList.add('hidden');
  post('close');
}

pickConfirmBtn.addEventListener('click', () => {
  if (!state.pickContext) return;
  pickConfirmBtn.disabled = true;
  pickConfirmBtn.textContent = 'Redeeming...';
  post('redeem', {
    categoryId: state.pickContext.categoryId,
    entryId: state.pickContext.entryId,
    selectedChoices: Array.from(state.pickSelected),
  });
  closePickModal();
  pickConfirmBtn.textContent = 'Confirm Selection';
});

pickCloseBtn.addEventListener('click', closePickModal);
closeBtn.addEventListener('click', closeMenu);

window.addEventListener('message', (event) => {
  const { action, data, success, entryId } = event.data || {};

  if (action === 'open') openMenu(data || {});
  if (action === 'close') app.classList.add('hidden');

  if (action === 'redeemResult') {
    if (success && entryId) state.redeemed.add(entryId);
    renderEntries();
  }
});

window.addEventListener('keydown', (event) => {
  if (event.key === 'Escape') closeMenu();
});
