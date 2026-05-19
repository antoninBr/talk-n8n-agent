(function initTalkAppCommon(global) {
	function getQueryParam(paramName) {
		const urlParams = new URLSearchParams(global.location.search);
		return urlParams.get(paramName);
	}

	function generateSessionId() {
		const timestamp = Date.now();
		const random = Math.floor(Math.random() * 10000);
		return `sess_${timestamp}_${random}`;
	}

	function getRandomDelay(range) {
		const [min, max] = range;
		return Math.floor(Math.random() * (max - min + 1)) + min;
	}

	function normalizeText(value) {
		return String(value || '').replace(/\s+/g, ' ').trim();
	}

	function hashString(value) {
		const normalized = normalizeText(value);
		let hash = 0;
		for (let index = 0; index < normalized.length; index += 1) {
			hash = ((hash << 5) - hash) + normalized.charCodeAt(index);
			hash |= 0;
		}
		return `hash_${Math.abs(hash)}`;
	}

	function readJsonStorage(key, fallbackValue) {
		try {
			const raw = global.localStorage.getItem(key);
			return raw ? JSON.parse(raw) : fallbackValue;
		} catch {
			return fallbackValue;
		}
	}

	function writeJsonStorage(key, value) {
		try {
			global.localStorage.setItem(key, JSON.stringify(value));
		} catch {
			return;
		}
	}

	function formatBytes(bytes) {
		if (bytes === 0 || bytes === undefined || bytes === null) {
			return '0 B';
		}

		const units = ['B', 'KB', 'MB', 'GB', 'TB'];
		const base = 1024;
		const exponent = Math.min(Math.floor(Math.log(bytes) / Math.log(base)), units.length - 1);
		const value = bytes / Math.pow(base, exponent);
		const formatted = exponent >= 2 ? value.toFixed(2) : Math.round(value);

		return `${formatted} ${units[exponent]}`;
	}

	function escapeHtml(value) {
		return String(value ?? '')
			.replace(/&/g, '&amp;')
			.replace(/</g, '&lt;')
			.replace(/>/g, '&gt;')
			.replace(/"/g, '&quot;')
			.replace(/'/g, '&#39;');
	}

	function showTimedMessage({
		element,
		text,
		duration = 5000,
		visibleClass = 'show',
		baseClass = '',
		type = '',
		typePrefix = '',
	}) {
		if (!element) {
			return;
		}

		const classNames = [];
		if (baseClass) {
			classNames.push(baseClass);
		}
		if (type && typePrefix) {
			classNames.push(`${typePrefix}${type}`);
		}
		if (classNames.length > 0) {
			element.className = classNames.join(' ');
		}

		element.textContent = text;
		element.classList.add(visibleClass);

		if (element.__talkAppHideTimer) {
			global.clearTimeout(element.__talkAppHideTimer);
		}

		element.__talkAppHideTimer = global.setTimeout(() => {
			element.classList.remove(visibleClass);
		}, duration);
	}

	function initDisclosureMenu({ toggleSelector, contentSelector, activeClass = 'active' }) {
		const toggle = global.document.querySelector(toggleSelector);
		const content = global.document.querySelector(contentSelector);
		if (!toggle || !content) {
			return null;
		}

		const close = () => content.classList.remove(activeClass);
		const toggleMenu = (event) => {
			event.stopPropagation();
			content.classList.toggle(activeClass);
		};

		toggle.addEventListener('click', toggleMenu);
		content.addEventListener('click', (event) => event.stopPropagation());
		global.document.addEventListener('click', (event) => {
			if (!content.contains(event.target) && event.target !== toggle) {
				close();
			}
		});

		return { toggle, content, close };
	}

	function createHermioneTipNotifier(options = {}) {
		const {
			endpointUrl,
			stackSelector = '.hermione-tip-stack',
			viewedStorageKey = 'hermione-viewed-tips',
			lifetimeMs = 15000,
			initialDelayRange = [12000, 22000],
			pollDelayRange = [70000, 140000],
			maxVisibleTips = 3,
			labels = {
				eyebrow: 'Chouette d Hermione',
				title: 'Conseil de Hermione',
				closeAriaLabel: 'Fermer cette notification',
				later: 'Plus tard',
				seen: 'Vue',
			},
			onError,
		} = options;

		if (!endpointUrl) {
			throw new Error('endpointUrl is required for createHermioneTipNotifier');
		}

		let timer = null;
		let lastShownHash = null;
		let isRunning = false;

		const getStack = () => global.document.querySelector(stackSelector);

		const readViewedTips = () => {
			const parsed = readJsonStorage(viewedStorageKey, []);
			return Array.isArray(parsed) ? parsed : [];
		};

		const writeViewedTips = (tips) => {
			writeJsonStorage(viewedStorageKey, tips.slice(-30));
		};

		const markTipAsViewed = (hash) => {
			const viewedTips = readViewedTips();
			if (!viewedTips.includes(hash)) {
				viewedTips.push(hash);
				writeViewedTips(viewedTips);
			}
		};

		const removeTip = (card) => {
			if (!card || card.classList.contains('is-leaving')) {
				return;
			}

			card.classList.add('is-leaving');
			global.setTimeout(() => {
				card.remove();
			}, 240);
		};

		const showTip = (message) => {
			const normalizedMessage = normalizeText(message);
			if (!normalizedMessage) {
				return;
			}

			const stack = getStack();
			if (!stack) {
				return;
			}

			const hash = hashString(normalizedMessage);
			const viewedTips = readViewedTips();
			if (viewedTips.includes(hash) || lastShownHash === hash) {
				return;
			}

			lastShownHash = hash;

			const card = global.document.createElement('article');
			card.className = 'hermione-tip';
			card.dataset.tipHash = hash;

			const header = global.document.createElement('div');
			header.className = 'hermione-tip__header';

			const headerCopy = global.document.createElement('div');
			const eyebrow = global.document.createElement('span');
			eyebrow.className = 'hermione-tip__eyebrow';
			eyebrow.textContent = labels.eyebrow;
			const title = global.document.createElement('strong');
			title.className = 'hermione-tip__title';
			title.textContent = labels.title;
			headerCopy.append(eyebrow, title);

			const dismissButton = global.document.createElement('button');
			dismissButton.type = 'button';
			dismissButton.className = 'hermione-tip__dismiss';
			dismissButton.setAttribute('aria-label', labels.closeAriaLabel);
			dismissButton.textContent = '×';
			dismissButton.addEventListener('click', () => removeTip(card));

			header.append(headerCopy, dismissButton);

			const content = global.document.createElement('p');
			content.className = 'hermione-tip__content';
			content.textContent = normalizedMessage;

			const actions = global.document.createElement('div');
			actions.className = 'hermione-tip__actions';

			const laterButton = global.document.createElement('button');
			laterButton.type = 'button';
			laterButton.className = 'hermione-tip__action hermione-tip__action--ghost';
			laterButton.textContent = labels.later;
			laterButton.addEventListener('click', () => removeTip(card));

			const seenButton = global.document.createElement('button');
			seenButton.type = 'button';
			seenButton.className = 'hermione-tip__action hermione-tip__action--seen';
			seenButton.textContent = labels.seen;
			seenButton.addEventListener('click', () => {
				markTipAsViewed(hash);
				removeTip(card);
			});

			actions.append(laterButton, seenButton);
			card.append(header, content, actions);

			stack.prepend(card);
			while (stack.children.length > maxVisibleTips) {
				stack.lastElementChild.remove();
			}

			global.setTimeout(() => {
				removeTip(card);
			}, lifetimeMs);
		};

		const fetchTip = async () => {
			const response = await global.fetch(endpointUrl, {
				method: 'GET',
				cache: 'no-store',
				headers: {
					Accept: 'text/plain, text/html',
				},
			});

			if (!response.ok) {
				throw new Error(`Hermione tip request failed with ${response.status}`);
			}

			return normalizeText(await response.text());
		};

		const schedule = (isInitial = false) => {
			if (!isRunning) {
				return;
			}

			global.clearTimeout(timer);
			const delay = isInitial ? getRandomDelay(initialDelayRange) : getRandomDelay(pollDelayRange);
			timer = global.setTimeout(async () => {
				try {
					const tip = await fetchTip();
					showTip(tip);
				} catch (error) {
					if (typeof onError === 'function') {
						onError(error);
					}
				} finally {
					schedule(false);
				}
			}, delay);
		};

		const start = () => {
			if (isRunning) {
				return;
			}
			isRunning = true;
			schedule(true);
		};

		const stop = () => {
			isRunning = false;
			global.clearTimeout(timer);
			timer = null;
		};

		return {
			start,
			stop,
			showTip,
		};
	}

	function createModelSelector(options = {}) {
		const {
			queryParam = 'model',
			defaultModel = 'local',
			legacyMap = {
				openai: 'lavoisier',
				remote: 'lavoisier',
			},
			buttonSelector = '.model-btn',
			notificationSelector = '.model-notification',
			transitionMs = 500,
			notificationMs = 2000,
			getNotificationText,
		} = options;

		const normalizeModel = (modelValue) => {
			if (!modelValue) {
				return defaultModel;
			}
			return legacyMap[modelValue] || modelValue;
		};

		const getCurrentModel = () => normalizeModel(getQueryParam(queryParam));

		const showNotification = (message) => {
			const notification = global.document.querySelector(notificationSelector);
			if (!notification || !message) {
				return;
			}

			notification.textContent = message;
			notification.classList.add('show');
			global.setTimeout(() => {
				notification.classList.remove('show');
			}, notificationMs);
		};

		const applyModelToUrl = (newModel) => {
			const url = new URL(global.location.href);
			url.searchParams.set(queryParam, newModel);
			global.history.replaceState({}, '', url);
		};

		const updateModel = (newModel, { reload = true } = {}) => {
			applyModelToUrl(newModel);
			if (reload) {
				global.location.reload();
			}
		};

		const init = () => {
			const currentModel = getCurrentModel();
			const buttons = global.document.querySelectorAll(buttonSelector);

			buttons.forEach((button) => {
				const modelType = normalizeModel(button.dataset.model);
				if (modelType === currentModel) {
					button.classList.add('active');
				}

				button.addEventListener('click', () => {
					if (modelType === currentModel) {
						return;
					}

					const message = typeof getNotificationText === 'function'
						? getNotificationText(modelType, currentModel)
						: '';

					showNotification(message);
					global.setTimeout(() => {
						updateModel(modelType);
					}, transitionMs);
				});
			});
		};

		return {
			getCurrentModel,
			init,
			normalizeModel,
			showNotification,
			updateModel,
		};
	}

	global.TalkAppCommon = {
		createHermioneTipNotifier,
		createModelSelector,
		escapeHtml,
		formatBytes,
		generateSessionId,
		getQueryParam,
		getRandomDelay,
		hashString,
		initDisclosureMenu,
		normalizeText,
		readJsonStorage,
		showTimedMessage,
		writeJsonStorage,
	};
})(window);