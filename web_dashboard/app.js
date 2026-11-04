// Daily Dough - Professional Store Administrator Web Application
// Target Firebase: https://dailydough-5480d-default-rtdb.firebaseio.com

const FIREBASE_BASE_URL = 'https://dailydough-5480d-default-rtdb.firebaseio.com';

// App State
const state = {
  isLoggedIn: false,
  currentUser: null,
  firebaseConnected: false,
  activeView: 'dashboard',
  searchQuery: '',
  products: [],
  transactions: [],
  customers: [],
  activeFilter: 'ALL'
};

// Initialize Application on DOM Ready
document.addEventListener('DOMContentLoaded', () => {
  checkFirebaseConnection();
  // Check if admin was previously logged in session (optional convenience)
  const savedAdmin = sessionStorage.getItem('dailyDoughAdminAuth');
  if (savedAdmin === 'true') {
    state.isLoggedIn = true;
    state.currentUser = 'admin';
    showWorkspace();
    refreshAllData();
  } else {
    showLogin();
  }
});

// ==========================================
// 1. Firebase Connectivity Check
// ==========================================
async function checkFirebaseConnection() {
  const badge = document.getElementById('firebaseBadge');
  const dot = badge ? badge.querySelector('.status-dot') : null;
  const text = document.getElementById('firebaseStatusText');

  try {
    const res = await fetch(`${FIREBASE_BASE_URL}/.json?shallow=true`, { method: 'GET' });
    if (res.ok) {
      state.firebaseConnected = true;
      if (dot) dot.className = 'status-dot';
      if (text) text.innerText = 'Firebase RTDB: Connected & Synchronized';
    } else if (res.status === 401 || (await res.text()).includes('Permission denied')) {
      state.firebaseConnected = true;
      if (dot) dot.className = 'status-dot';
      if (text) text.innerText = 'Firebase RTDB: Connected (Auth Active)';
    } else {
      if (dot) dot.className = 'status-dot error';
      if (text) text.innerText = `Firebase RTDB: HTTP ${res.status}`;
    }
  } catch (err) {
    if (dot) dot.className = 'status-dot syncing';
    if (text) text.innerText = 'Firebase RTDB: Standby Mode';
  }
}

// ==========================================
// 2. Authentication & Session Management
// ==========================================
function showLogin() {
  document.getElementById('viewLogin').style.display = 'flex';
  document.getElementById('viewLogin').classList.add('active');
  document.getElementById('adminWorkspace').style.display = 'none';
}

function showWorkspace() {
  document.getElementById('viewLogin').style.display = 'none';
  document.getElementById('viewLogin').classList.remove('active');
  document.getElementById('adminWorkspace').style.display = 'flex';
  switchView('dashboard');
}

async function handleLogin(e) {
  e.preventDefault();
  const alertBox = document.getElementById('loginAlert');
  alertBox.style.display = 'none';

  const usernameInput = document.getElementById('usernameInput').value.trim();
  const passwordInput = document.getElementById('passwordInput').value.trim();

  if (!usernameInput) {
    showLoginError('Please enter administrator username.');
    return;
  }
  if (!passwordInput) {
    showLoginError('Please enter administrator password.');
    return;
  }

  // Strict Role Enforcement: Customers must not access the admin web portal
  if (usernameInput.toLowerCase() !== 'admin') {
    showLoginError(
      'Access Denied: Customer accounts must use the Daily Dough Customer Mobile App. This web portal is strictly restricted to store administrators.'
    );
    return;
  }

  // Verify Admin credentials in Firebase RTDB /users or fallback admin account
  let authenticated = false;
  try {
    const res = await fetch(`${FIREBASE_BASE_URL}/users.json`);
    if (res.ok) {
      const usersData = await res.json();
      if (usersData && typeof usersData === 'object') {
        for (const key of Object.keys(usersData)) {
          const u = usersData[key];
          if (u.username === 'admin' && u.password === passwordInput) {
            authenticated = true;
            break;
          }
        }
      }
    }
  } catch (_) {}

  // Standard Lab 07/08 expected admin credential check
  if (!authenticated && usernameInput === 'admin' && passwordInput === 'admin123') {
    authenticated = true;
  }

  if (authenticated) {
    state.isLoggedIn = true;
    state.currentUser = 'admin';
    sessionStorage.setItem('dailyDoughAdminAuth', 'true');

    alertToast('Welcome to Daily Dough Store Administrator Workspace!');
    showWorkspace();
    await refreshAllData();
  } else {
    showLoginError('Invalid Administrator Username or Password.');
  }
}

function showLoginError(msg) {
  const alertBox = document.getElementById('loginAlert');
  alertBox.innerText = msg;
  alertBox.style.display = 'block';
}

function handleLogout() {
  state.isLoggedIn = false;
  state.currentUser = null;
  sessionStorage.removeItem('dailyDoughAdminAuth');
  
  const form = document.getElementById('loginForm');
  if (form) form.reset();
  
  const passInput = document.getElementById('passwordInput');
  if (passInput) passInput.type = 'password';
  
  const toggleBtn = document.getElementById('togglePasswordBtn');
  if (toggleBtn) toggleBtn.innerText = '👁️';

  showLogin();
  alertToast('Logged out of Administrator Portal.');
}

function togglePasswordVisibility() {
  const passInput = document.getElementById('passwordInput');
  const btn = document.getElementById('togglePasswordBtn');
  if (!passInput) return;
  if (passInput.type === 'password') {
    passInput.type = 'text';
    if (btn) btn.innerText = '🙈';
  } else {
    passInput.type = 'password';
    if (btn) btn.innerText = '👁️';
  }
}

// ==========================================
// 3. Navigation & View Routing
// ==========================================
function switchView(viewName) {
  if (!state.isLoggedIn) {
    showLogin();
    return;
  }

  state.activeView = viewName;

  // Update Sidebar active state
  const navMap = {
    dashboard: 'navDashboard',
    orders: 'navOrders',
    products: 'navProducts',
    customers: 'navCustomers',
    payments: 'navPayments'
  };

  Object.keys(navMap).forEach(key => {
    const el = document.getElementById(navMap[key]);
    if (el) el.classList.toggle('active', key === viewName);
  });

  // Toggle View Sections inside main workspace
  const views = ['viewDashboard', 'viewOrders', 'viewProducts', 'viewCustomers', 'viewPayments'];
  views.forEach(v => {
    const el = document.getElementById(v);
    if (el) el.classList.remove('active');
  });

  const targetViewId = 'view' + viewName.charAt(0).toUpperCase() + viewName.slice(1);
  const targetView = document.getElementById(targetViewId);
  if (targetView) targetView.classList.add('active');

  // Trigger view-specific re-renders
  if (viewName === 'dashboard') {
    renderDashboard();
  } else if (viewName === 'orders') {
    renderAdminOrders();
  } else if (viewName === 'products') {
    renderAdminProducts();
  } else if (viewName === 'customers') {
    renderAdminCustomers();
  } else if (viewName === 'payments') {
    renderAdminPayments();
  }
}

// ==========================================
// 4. Data Synchronization (Firebase RTDB)
// ==========================================
async function refreshAllData() {
  try {
    await Promise.all([
      refreshProducts(false),
      refreshTransactions(false),
      refreshCustomers(false)
    ]);
    updateKPIs();
    renderDashboard();
    renderAdminOrders();
    renderAdminProducts();
    renderAdminCustomers();
    renderAdminPayments();
    alertToast('Store data synchronized with Firebase RTDB!');
  } catch (e) {
    console.error('Data refresh error:', e);
  }
}

async function refreshProducts(render = true) {
  try {
    const res = await fetch(`${FIREBASE_BASE_URL}/products.json`);
    if (res.ok) {
      const data = await res.json();
      const list = [];
      if (data && typeof data === 'object') {
        Object.keys(data).forEach(k => {
          list.push({ id: k, ...data[k] });
        });
      }
      state.products = list;
    }
  } catch (_) {}
  if (render) {
    renderAdminProducts();
    updateKPIs();
  }
}

async function refreshTransactions(render = true) {
  try {
    const res = await fetch(`${FIREBASE_BASE_URL}/transactions.json`);
    if (res.ok) {
      const data = await res.json();
      const list = [];
      if (data && typeof data === 'object') {
        Object.keys(data).forEach(k => {
          list.push({ id: k, ...data[k] });
        });
      }
      // Sort newest first
      list.sort((a, b) => new Date(b.timestamp || 0) - new Date(a.timestamp || 0));
      state.transactions = list;
    }
  } catch (_) {}
  if (render) {
    renderAdminOrders();
    renderAdminPayments();
    renderDashboard();
    updateKPIs();
  }
}

async function refreshCustomers(render = true) {
  try {
    const res = await fetch(`${FIREBASE_BASE_URL}/customers.json`);
    if (res.ok) {
      const data = await res.json();
      const list = [];
      if (data && typeof data === 'object') {
        Object.keys(data).forEach(k => {
          const item = data[k];
          // Security: Exclude customer passwords
          list.push({
            id: k,
            fullName: item.fullName || 'Customer',
            email: item.email || '-',
            username: item.username || k,
            phone: item.phone || '-',
            createdAt: item.createdAt || 'Recent',
            accountType: item.accountType || 'Customer',
          });
        });
      }
      state.customers = list;
    }
  } catch (_) {}
  if (render) {
    renderAdminCustomers();
    updateKPIs();
  }
}

// ==========================================
// 5. KPI Metrics & Header Updates
// ==========================================
function updateKPIs() {
  const totalRev = state.transactions.reduce((sum, t) => sum + (Number(t.totalAmount) || 0), 0);
  const totalOrders = state.transactions.length;

  const pendingOrders = state.transactions.filter(t => {
    const s = (t.status || '').toLowerCase().trim();
    return s === 'order placed' || s === 'preparing food' || s === 'ready for delivery';
  }).length;

  const completedOrders = state.transactions.filter(t => {
    const s = (t.status || '').toLowerCase().trim();
    return s === 'order delivered' || s === 'completed' || s === 'delivered';
  }).length;

  const totalCustomers = state.customers.length;

  // Update Metric Card elements
  const revEl = document.getElementById('kpiRevenue');
  const ordEl = document.getElementById('kpiOrders');
  const penEl = document.getElementById('kpiPendingOrders');
  const comEl = document.getElementById('kpiCompletedOrders');
  const cusEl = document.getElementById('kpiCustomers');

  if (revEl) revEl.innerText = `₱${totalRev.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  if (ordEl) ordEl.innerText = totalOrders.toLocaleString();
  if (penEl) penEl.innerText = pendingOrders.toLocaleString();
  if (comEl) comEl.innerText = completedOrders.toLocaleString();
  if (cusEl) cusEl.innerText = totalCustomers.toLocaleString();

  // Top header pending notification badge
  const headerPendingBadge = document.getElementById('headerPendingCount');
  if (headerPendingBadge) {
    headerPendingBadge.innerText = pendingOrders;
    headerPendingBadge.style.display = pendingOrders > 0 ? 'inline-block' : 'none';
  }
}

// ==========================================
// 6. Dashboard: SVG Sales Trend Chart & Analytics
// ==========================================
function renderDashboard() {
  updateKPIs();
  renderSalesTrendChart();
  renderMenuItemDistribution();
  renderDashboardRecentOrders();
}

function renderSalesTrendChart() {
  const container = document.getElementById('salesChartContainer');
  if (!container) return;

  if (state.transactions.length === 0) {
    container.innerHTML = `
      <div style="display: flex; height: 100%; align-items: center; justify-content: center; color: var(--text-muted); font-size: 13px;">
        No transaction records available in Firebase RTDB.
      </div>`;
    return;
  }

  // Aggregate total sales strictly by transaction date
  const salesByDate = {};
  state.transactions.forEach(t => {
    if (!t.timestamp) return;
    // Extract date portion (YYYY-MM-DD or readable)
    const rawDate = t.timestamp.toString().split(' ')[0] || 'Unknown';
    const amt = Number(t.totalAmount) || 0;
    salesByDate[rawDate] = (salesByDate[rawDate] || 0) + amt;
  });

  const dates = Object.keys(salesByDate).sort();
  if (dates.length === 0) {
    container.innerHTML = `<div style="text-align: center; padding: 40px; color: var(--text-muted);">No dated transactions found.</div>`;
    return;
  }

  const values = dates.map(d => salesByDate[d]);
  const maxVal = Math.max(...values, 100);

  // SVG dimensions
  const svgWidth = 620;
  const svgHeight = 220;
  const padLeft = 65;
  const padRight = 30;
  const padTop = 25;
  const padBottom = 35;
  const chartW = svgWidth - padLeft - padRight;
  const chartH = svgHeight - padTop - padBottom;

  // Calculate points
  const points = dates.map((d, i) => {
    const x = padLeft + (dates.length > 1 ? (i / (dates.length - 1)) * chartW : chartW / 2);
    const y = padTop + chartH - (salesByDate[d] / maxVal) * chartH;
    return { x, y, date: d, amount: salesByDate[d] };
  });

  const polylineStr = points.map(p => `${p.x.toFixed(1)},${p.y.toFixed(1)}`).join(' ');
  const areaPolyStr = `${padLeft},${padTop + chartH} ` + polylineStr + ` ${padLeft + chartW},${padTop + chartH}`;

  // Y-axis grid levels (4 ticks)
  const ticks = [0, maxVal * 0.33, maxVal * 0.66, maxVal];
  const gridLines = ticks.map(tick => {
    const y = padTop + chartH - (tick / maxVal) * chartH;
    return `
      <line x1="${padLeft}" y1="${y}" x2="${padLeft + chartW}" y2="${y}" stroke="#f0ebe1" stroke-width="1" stroke-dasharray="3,3" />
      <text x="${padLeft - 10}" y="${y + 4}" fill="#786c65" font-size="10" text-anchor="end" font-family="Inter, sans-serif">₱${Math.round(tick).toLocaleString()}</text>
    `;
  }).join('');

  // X-axis date labels
  const dateLabels = points.map(p => {
    // Format date nicely (e.g. "Oct 27" or "Nov 02")
    const parts = p.date.split('-');
    const label = parts.length === 3 ? `${parts[1]}/${parts[2]}` : p.date;
    return `<text x="${p.x}" y="${padTop + chartH + 20}" fill="#786c65" font-size="10" text-anchor="middle" font-family="Inter, sans-serif">${label}</text>`;
  }).join('');

  // Data dots and hover titles
  const dataDots = points.map(p => `
    <circle cx="${p.x}" cy="${p.y}" r="4.5" fill="#D97706" stroke="#ffffff" stroke-width="2" style="cursor: pointer;">
      <title>${p.date}: ₱${p.amount.toLocaleString()}</title>
    </circle>
  `).join('');

  const svgHtml = `
    <svg viewBox="0 0 ${svgWidth} ${svgHeight}" preserveAspectRatio="xMidYMid meet" style="width: 100%; height: 100%;">
      <defs>
        <linearGradient id="salesGradient" x1="0%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" stop-color="#D97706" stop-opacity="0.32" />
          <stop offset="100%" stop-color="#D97706" stop-opacity="0.02" />
        </linearGradient>
      </defs>
      <!-- Horizontal Grid Lines -->
      ${gridLines}
      <!-- Shaded Area Under Curve -->
      <polygon points="${areaPolyStr}" fill="url(#salesGradient)" />
      <!-- Line Curve -->
      <polyline points="${polylineStr}" fill="none" stroke="#D97706" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" />
      <!-- Data Points -->
      ${dataDots}
      <!-- X-axis Labels -->
      ${dateLabels}
    </svg>
  `;

  container.innerHTML = svgHtml;
}

function renderMenuItemDistribution() {
  const container = document.getElementById('distributionList');
  if (!container) return;

  const itemCounts = {};
  let grandTotalUnits = 0;

  state.transactions.forEach(t => {
    if (!t.items) return;
    const itemsList = Array.isArray(t.items) ? t.items : [t.items.toString()];
    itemsList.forEach(itemStr => {
      // Clean item name and count if "Name x Quantity" format
      let name = itemStr;
      let qty = 1;
      if (typeof itemStr === 'string' && itemStr.includes(' x ')) {
        const parts = itemStr.split(' x ');
        name = parts[0].trim();
        qty = parseInt(parts[1], 10) || 1;
      }
      itemCounts[name] = (itemCounts[name] || 0) + qty;
      grandTotalUnits += qty;
    });
  });

  const sortedItems = Object.keys(itemCounts)
    .map(name => ({ name, count: itemCounts[name] }))
    .sort((a, b) => b.count - a.count)
    .slice(0, 5);

  if (sortedItems.length === 0 || grandTotalUnits === 0) {
    container.innerHTML = `<div style="text-align: center; padding: 20px; color: var(--text-muted); font-size: 13px;">No item orders recorded.</div>`;
    return;
  }

  container.innerHTML = sortedItems.map(item => {
    const pct = Math.round((item.count / grandTotalUnits) * 100);
    return `
      <div class="distribution-item">
        <div class="dist-meta">
          <span class="name">${escapeHtml(item.name)}</span>
          <span class="count">${item.count} ordered (${pct}%)</span>
        </div>
        <div class="dist-bar-track">
          <div class="dist-bar-fill" style="width: ${pct}%;"></div>
        </div>
      </div>
    `;
  }).join('');
}

function renderDashboardRecentOrders() {
  const tbody = document.getElementById('dashboardRecentOrdersBody');
  if (!tbody) return;
  tbody.innerHTML = '';

  let list = filterByQuery(state.transactions, state.searchQuery);
  const recent = list.slice(0, 6);

  if (recent.length === 0) {
    tbody.innerHTML = `<tr><td colspan="8" style="text-align: center; padding: 24px; color: var(--text-muted);">No transactions match your search or records are empty.</td></tr>`;
    return;
  }

  recent.forEach(order => {
    const tr = document.createElement('tr');
    const itemsSummary = Array.isArray(order.items) ? order.items.join(', ') : (order.items || '-');
    const shortId = (order.id || '').length > 10 ? order.id.slice(0, 10) + '...' : order.id;

    tr.innerHTML = `
      <td><code title="${escapeHtml(order.id)}">${escapeHtml(shortId)}</code></td>
      <td>
        <strong>${escapeHtml(order.customerName || order.username || 'Customer')}</strong>
      </td>
      <td style="color: var(--text-muted); font-size: 12px;">${escapeHtml(order.timestamp || '-')}</td>
      <td style="color: #475569; font-size: 12px; max-width: 180px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;" title="${escapeHtml(itemsSummary)}">${escapeHtml(itemsSummary)}</td>
      <td><span class="badge" style="background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1;">${escapeHtml(order.paymentMethod || 'COD')}</span></td>
      <td><strong style="color: #b45309;">₱${Number(order.totalAmount || 0).toLocaleString()}</strong></td>
      <td>${getStatusBadgeHtml(order.status)}</td>
      <td>
        <select class="status-select" onchange="handleAdminChangeOrderStatus('${order.id}', this.value)">
          ${buildStatusOptions(order.status)}
        </select>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

// ==========================================
// 7. Orders Management View
// ==========================================
function renderAdminOrders() {
  const tbody = document.getElementById('ordersTableBody');
  if (!tbody) return;
  tbody.innerHTML = '';

  let list = state.transactions;

  // Filter by Stage
  if (state.activeFilter !== 'ALL') {
    list = list.filter(t => (t.status || '').toLowerCase() === state.activeFilter.toLowerCase());
  }

  // Filter by Global Search
  list = filterByQuery(list, state.searchQuery);

  if (list.length === 0) {
    tbody.innerHTML = `<tr><td colspan="8" style="text-align: center; padding: 28px; color: var(--text-muted);">No customer orders found matching current filter or search criteria.</td></tr>`;
    return;
  }

  list.forEach(order => {
    const tr = document.createElement('tr');
    const itemsSummary = Array.isArray(order.items) ? order.items.join(', ') : (order.items || '-');

    tr.innerHTML = `
      <td><code>${escapeHtml(order.id)}</code></td>
      <td>
        <strong>${escapeHtml(order.customerName || 'Customer')}</strong>
        <div style="font-size: 11px; color: var(--text-muted);">@${escapeHtml(order.username || 'user')}</div>
      </td>
      <td style="font-size: 12px; color: #475569; max-width: 160px; overflow: hidden; text-overflow: ellipsis;">${escapeHtml(order.address || '-')}</td>
      <td style="font-size: 12px; color: #334155; max-width: 220px;" title="${escapeHtml(itemsSummary)}">${escapeHtml(itemsSummary)}</td>
      <td><span class="badge" style="background: #f1f5f9; color: #334155; border: 1px solid #cbd5e1;">${escapeHtml(order.paymentMethod || 'COD')}</span></td>
      <td><strong style="color: #b45309;">₱${Number(order.totalAmount || 0).toLocaleString()}</strong></td>
      <td>${getStatusBadgeHtml(order.status)}</td>
      <td>
        <select class="status-select" onchange="handleAdminChangeOrderStatus('${order.id}', this.value)">
          ${buildStatusOptions(order.status)}
        </select>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function filterOrders(status) {
  state.activeFilter = status;
  renderAdminOrders();
}

async function handleAdminChangeOrderStatus(orderId, newStatus) {
  const order = state.transactions.find(t => t.id === orderId);
  if (!order) return;

  const previousStatus = order.status;
  order.status = newStatus;

  try {
    const res = await fetch(`${FIREBASE_BASE_URL}/transactions/${orderId}.json`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status: newStatus })
    });
    if (!res.ok) {
      console.warn('Firebase PATCH returned status', res.status);
    }
  } catch (err) {
    console.error('Firebase PATCH error:', err);
  }

  updateKPIs();
  renderAdminOrders();
  renderDashboard();
  renderAdminPayments();
  alertToast(`Order #${orderId} stage updated to "${newStatus}"!`);
}

function getStatusBadgeHtml(status) {
  const s = (status || 'Order Placed').trim().toLowerCase();
  if (s.includes('delivered') || s.includes('completed')) {
    return `<span class="badge badge-delivered">✅ ${escapeHtml(status)}</span>`;
  } else if (s.includes('out for delivery') || s.includes('delivering')) {
    return `<span class="badge badge-delivering">🛵 ${escapeHtml(status)}</span>`;
  } else if (s.includes('ready')) {
    return `<span class="badge badge-ready">📦 ${escapeHtml(status)}</span>`;
  } else if (s.includes('preparing') || s.includes('food')) {
    return `<span class="badge badge-preparing">🍳 ${escapeHtml(status)}</span>`;
  } else {
    return `<span class="badge badge-placed">🕒 ${escapeHtml(status)}</span>`;
  }
}

function buildStatusOptions(currentStatus) {
  const stages = [
    'Order Placed',
    'Preparing Food',
    'Ready for Delivery',
    'Out for Delivery',
    'Order Delivered',
    'Completed'
  ];
  return stages.map(stage => {
    const isSelected = (currentStatus || '').toLowerCase() === stage.toLowerCase();
    return `<option value="${stage}" ${isSelected ? 'selected' : ''}>${stage}</option>`;
  }).join('');
}

// ==========================================
// 8. Products Catalog Management (CRUD)
// ==========================================
function renderAdminProducts() {
  const tbody = document.getElementById('productsTableBody');
  if (!tbody) return;
  tbody.innerHTML = '';

  let list = filterByQuery(state.products, state.searchQuery);

  if (list.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5" style="text-align: center; padding: 24px; color: var(--text-muted);">No products found matching criteria. Use form above to add products.</td></tr>`;
    return;
  }

  list.forEach(p => {
    const tr = document.createElement('tr');
    const imgHtml = p.imageUrl
      ? `<img src="${escapeHtml(p.imageUrl)}" style="width: 44px; height: 44px; object-fit: cover; border-radius: 8px; border: 1px solid var(--border-color);" onerror="this.outerHTML='<span style=\\'font-size: 26px;\\'>🍩</span>'">`
      : `<span style="font-size: 26px;">🍩</span>`;

    tr.innerHTML = `
      <td>${imgHtml}</td>
      <td><strong>${escapeHtml(p.name)}</strong></td>
      <td><strong style="color: #b45309;">₱${Number(p.price || 0).toLocaleString()}</strong></td>
      <td style="color: #64748b; font-size: 13px;">${escapeHtml(p.details || '-')}</td>
      <td style="text-align: right;">
        <button class="btn btn-outline btn-sm" onclick="showEditProductModal('${p.id}')">✏️ Edit</button>
        <button class="btn btn-danger btn-sm" style="margin-left: 6px;" onclick="handleAdminDeleteProduct('${p.id}', '${escapeHtml(p.name)}')">🗑️ Delete</button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

async function handleAdminAddProduct(e) {
  e.preventDefault();
  const name = document.getElementById('adminNewName').value.trim();
  const price = parseFloat(document.getElementById('adminNewPrice').value);
  const imageUrl = document.getElementById('adminNewImageUrl').value.trim();
  const details = document.getElementById('adminNewDetails').value.trim();

  if (!name || isNaN(price) || price <= 0) {
    alertToast('Please enter a valid product name and positive price.');
    return;
  }
  if (!imageUrl) {
    alertToast('Product photo URL is required.');
    return;
  }

  const newProd = { name, price, imageUrl, details };

  try {
    const res = await fetch(`${FIREBASE_BASE_URL}/products.json`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newProd)
    });
    if (res.ok) {
      const data = await res.json();
      newProd.id = data.name || `prod_${Date.now()}`;
    } else {
      newProd.id = `prod_${Date.now()}`;
    }
  } catch (_) {
    newProd.id = `prod_${Date.now()}`;
  }

  state.products.unshift(newProd);
  document.getElementById('adminAddProductForm').reset();
  renderAdminProducts();
  alertToast(`Product "${name}" added to Firebase store catalog!`);
}

function showEditProductModal(id) {
  const prod = state.products.find(p => p.id === id);
  if (!prod) return;

  document.getElementById('editProdId').value = prod.id;
  document.getElementById('editProdName').value = prod.name;
  document.getElementById('editProdPrice').value = prod.price;
  document.getElementById('editProdImageUrl').value = prod.imageUrl || '';
  document.getElementById('editProdDetails').value = prod.details || '';
  document.getElementById('editProductModal').style.display = 'flex';
}

function closeEditProductModal() {
  document.getElementById('editProductModal').style.display = 'none';
}

async function handleSaveEditProduct(e) {
  e.preventDefault();
  const id = document.getElementById('editProdId').value;
  const name = document.getElementById('editProdName').value.trim();
  const price = parseFloat(document.getElementById('editProdPrice').value);
  const imageUrl = document.getElementById('editProdImageUrl').value.trim();
  const details = document.getElementById('editProdDetails').value.trim();

  if (!name || isNaN(price) || price <= 0) {
    alertToast('Please provide a valid product name and price.');
    return;
  }

  const updateData = { name, price, details, imageUrl };

  try {
    await fetch(`${FIREBASE_BASE_URL}/products/${id}.json`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(updateData)
    });
  } catch (_) {}

  const prod = state.products.find(p => p.id === id);
  if (prod) {
    prod.name = name;
    prod.price = price;
    prod.details = details;
    prod.imageUrl = imageUrl;
  }

  closeEditProductModal();
  renderAdminProducts();
  alertToast(`Product "${name}" updated in Firebase!`);
}

async function handleAdminDeleteProduct(id, name) {
  if (!confirm(`Are you sure you want to delete "${name}" from Firebase Realtime Database?`)) return;

  try {
    await fetch(`${FIREBASE_BASE_URL}/products/${id}.json`, { method: 'DELETE' });
  } catch (_) {}

  state.products = state.products.filter(p => p.id !== id);
  renderAdminProducts();
  alertToast(`Product "${name}" removed from catalog!`);
}

// ==========================================
// 9. Customers Management View
// ==========================================
function renderAdminCustomers() {
  const tbody = document.getElementById('customersTableBody');
  if (!tbody) return;
  tbody.innerHTML = '';

  let list = filterByQuery(state.customers, state.searchQuery);

  if (list.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; padding: 24px; color: var(--text-muted);">No customers found matching search.</td></tr>`;
    return;
  }

  list.forEach(c => {
    const tr = document.createElement('tr');
    // Calculate customer's order count
    const custOrdersCount = state.transactions.filter(t => {
      const u = (t.username || '').toLowerCase();
      const n = (t.customerName || '').toLowerCase();
      return u === c.username.toLowerCase() || n === c.fullName.toLowerCase();
    }).length;

    tr.innerHTML = `
      <td><strong>${escapeHtml(c.fullName)}</strong></td>
      <td>${escapeHtml(c.email)}</td>
      <td><code>@${escapeHtml(c.username)}</code></td>
      <td>${escapeHtml(c.phone || '-')}</td>
      <td style="color: var(--text-muted); font-size: 12px;">${escapeHtml(c.createdAt)}</td>
      <td><span class="badge" style="background: #e0f2fe; color: #0369a1;">${custOrdersCount} orders</span></td>
      <td><span class="badge" style="background: #fef3c7; color: #b45309; border: 1px solid #fde68a;">Customer</span></td>
    `;
    tbody.appendChild(tr);
  });
}

// ==========================================
// 10. Payments & Sales Breakdown
// ==========================================
function renderAdminPayments() {
  let codTotal = 0, codCount = 0;
  let gcashTotal = 0, gcashCount = 0;
  let cardTotal = 0, cardCount = 0;

  state.transactions.forEach(t => {
    const amt = Number(t.totalAmount) || 0;
    const method = (t.paymentMethod || '').toLowerCase();

    if (method.includes('cash') || method.includes('cod')) {
      codTotal += amt;
      codCount++;
    } else if (method.includes('gcash')) {
      gcashTotal += amt;
      gcashCount++;
    } else {
      cardTotal += amt;
      cardCount++;
    }
  });

  const payCodTotal = document.getElementById('payCodTotal');
  const payCodCount = document.getElementById('payCodCount');
  const payGcashTotal = document.getElementById('payGcashTotal');
  const payGcashCount = document.getElementById('payGcashCount');
  const payCardTotal = document.getElementById('payCardTotal');
  const payCardCount = document.getElementById('payCardCount');

  if (payCodTotal) payCodTotal.innerText = `₱${codTotal.toLocaleString()}`;
  if (payCodCount) payCodCount.innerText = `${codCount} orders`;
  if (payGcashTotal) payGcashTotal.innerText = `₱${gcashTotal.toLocaleString()}`;
  if (payGcashCount) payGcashCount.innerText = `${gcashCount} orders`;
  if (payCardTotal) payCardTotal.innerText = `₱${cardTotal.toLocaleString()}`;
  if (payCardCount) payCardCount.innerText = `${cardCount} orders`;

  const tbody = document.getElementById('paymentsTableBody');
  if (!tbody) return;
  tbody.innerHTML = '';

  let list = filterByQuery(state.transactions, state.searchQuery);

  if (list.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" style="text-align: center; padding: 24px; color: var(--text-muted);">No payment records available.</td></tr>`;
    return;
  }

  list.forEach(t => {
    const tr = document.createElement('tr');
    const isCompleted = (t.status || '').toLowerCase().includes('delivered') || (t.status || '').toLowerCase().includes('completed');
    const verBadge = isCompleted
      ? `<span class="badge" style="background: #dcfce7; color: #166534;">Verified & Settled</span>`
      : `<span class="badge" style="background: #fef9c3; color: #854d0e;">Pending Fulfillment</span>`;

    tr.innerHTML = `
      <td><code>${escapeHtml(t.id)}</code></td>
      <td><strong>${escapeHtml(t.customerName || t.username || 'Customer')}</strong></td>
      <td><span class="badge" style="background: #f8fafc; color: #334155; border: 1px solid #cbd5e1;">${escapeHtml(t.paymentMethod || 'COD')}</span></td>
      <td><strong style="color: #b45309;">₱${Number(t.totalAmount || 0).toLocaleString()}</strong></td>
      <td style="color: var(--text-muted); font-size: 12px;">${escapeHtml(t.timestamp || '-')}</td>
      <td>${getStatusBadgeHtml(t.status)}</td>
      <td>${verBadge}</td>
    `;
    tbody.appendChild(tr);
  });
}

// ==========================================
// 11. Global Real-time Search
// ==========================================
function handleGlobalSearch(query) {
  state.searchQuery = (query || '').trim().toLowerCase();
  
  if (state.activeView === 'dashboard') {
    renderDashboardRecentOrders();
  } else if (state.activeView === 'orders') {
    renderAdminOrders();
  } else if (state.activeView === 'products') {
    renderAdminProducts();
  } else if (state.activeView === 'customers') {
    renderAdminCustomers();
  } else if (state.activeView === 'payments') {
    renderAdminPayments();
  }
}

function filterByQuery(list, q) {
  if (!q) return list;
  return list.filter(item => {
    const serialized = JSON.stringify(item).toLowerCase();
    return serialized.includes(q);
  });
}

// ==========================================
// 12. Utility & Notification Helpers
// ==========================================
function escapeHtml(text) {
  if (!text) return '';
  return text.toString().replace(/[&<>"']/g, m => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;'
  })[m]);
}

function alertToast(msg) {
  const existing = document.getElementById('appToast');
  if (existing) existing.remove();

  const toast = document.createElement('div');
  toast.id = 'appToast';
  toast.style.cssText = `
    position: fixed;
    bottom: 24px;
    right: 24px;
    background: #1D120C;
    color: #F9F6F2;
    border-left: 4px solid #D97706;
    padding: 14px 22px;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 600;
    font-family: 'Inter', sans-serif;
    box-shadow: 0 10px 25px -5px rgba(0,0,0,0.3);
    z-index: 99999;
    display: flex;
    align-items: center;
    gap: 10px;
  `;
  toast.innerHTML = `<span>ℹ️</span> <span>${escapeHtml(msg)}</span>`;
  document.body.appendChild(toast);
  setTimeout(() => {
    if (toast.parentNode) toast.remove();
  }, 3500);
}

// ==========================================
// 13. Playful 4 Mini Donuts Click Interaction (Login & Landing Page)
// ==========================================
document.addEventListener('click', (e) => {
  // Spawns 4 small charming donuts (16px) that burst gently outward
  const configs = [
    { dx: '-16px', dy: '-20px', rot: '-25deg', glaze: '#F472B6' }, // Strawberry Pink
    { dx: '16px', dy: '-20px', rot: '25deg', glaze: '#78350F' },  // Chocolate
    { dx: '-22px', dy: '8px', rot: '-40deg', glaze: '#10B981' },  // Matcha
    { dx: '22px', dy: '8px', rot: '40deg', glaze: '#F59E0B' }     // Caramel Cream
  ];

  configs.forEach(cfg => {
    const donut = document.createElement('div');
    donut.className = 'click-donut';
    donut.style.left = `${e.clientX}px`;
    donut.style.top = `${e.clientY}px`;
    donut.style.setProperty('--dx', cfg.dx);
    donut.style.setProperty('--dy', cfg.dy);
    donut.style.setProperty('--rot', cfg.rot);

    donut.innerHTML = `
      <svg viewBox="0 0 20 20" width="16" height="16" style="display:block;">
        <circle cx="10" cy="10" r="9" fill="#D97706" />
        <circle cx="10" cy="10" r="7.5" fill="${cfg.glaze}" />
        <circle cx="10" cy="10" r="3" fill="#FFFBEB" />
        <rect x="8" y="3.5" width="2" height="1" rx="0.5" fill="#FFFFFF" transform="rotate(20 9 4)" />
        <rect x="13.5" y="7" width="2" height="1" rx="0.5" fill="#FEF08A" transform="rotate(-30 14.5 7.5)" />
        <rect x="5" y="10" width="2" height="1" rx="0.5" fill="#FFFFFF" transform="rotate(45 6 10.5)" />
      </svg>
    `;

    document.body.appendChild(donut);
    setTimeout(() => {
      if (donut.parentNode) donut.remove();
    }, 650);
  });
});

