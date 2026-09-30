const hud = document.getElementById('hud');
const el = {};
document.querySelectorAll('[data-el]').forEach((node) => { el[node.dataset.el] = node; });

const rings = {};
document.querySelectorAll('[data-ring]').forEach((node) => {
    rings[node.dataset.ring] = { node, fill: node.querySelector('.ring__fill') };
});

const settings = {
    autoHide: { armor: true, stamina: true, statusAbove: undefined },
    lowThreshold: 20,
};

// Estados que parpadean en rojo cuando bajan del umbral
const WARN_ON_LOW = new Set(['health', 'hunger', 'thirst', 'oxygen']);

function toggle(node, className, state) {
    if (node.classList.contains(className) !== state) node.classList.toggle(className, state);
}

function setText(node, value) {
    const text = String(value);
    if (node.textContent !== text) node.textContent = text;
}

function setRing(name, value, visible = true) {
    const ring = rings[name];
    const show = visible && value !== undefined && value !== null;

    toggle(ring.node, 'is-off', !show);
    if (!show) return;

    ring.fill.style.strokeDashoffset = 100 - Math.max(0, Math.min(100, value));
    toggle(ring.node, 'is-low', WARN_ON_LOW.has(name) && value <= settings.lowThreshold);
}

function updatePlayer(p) {
    const { autoHide } = settings;
    const statusVisible = (v) => autoHide.statusAbove == null || v <= autoHide.statusAbove;

    setRing('health', p.health);
    setRing('armor', p.armor, !(autoHide.armor && p.armor <= 0));
    setRing('hunger', p.hunger, statusVisible(p.hunger));
    setRing('thirst', p.thirst, statusVisible(p.thirst));
    setRing('stamina', p.stamina, !(autoHide.stamina && p.stamina >= 99));
    setRing('oxygen', p.oxygen);

    const voice = p.voice;
    setRing('voice', voice ? (voice.mode / voice.modes) * 100 : undefined);
    if (voice) {
        toggle(rings.voice.node, 'is-talking', voice.talking && !voice.radio);
        toggle(rings.voice.node, 'is-radio', !!voice.radio);
    }
}

function updateVehicle(v) {
    toggle(el.vehicle, 'is-off', !v);
    if (!v) return;

    setText(el.speed, v.speed);
    setText(el.gear, v.gear);

    el.rpm.style.width = `${v.rpm}%`;
    toggle(el.rpm, 'is-high', v.rpm >= 90);

    const hasFuel = v.fuel !== undefined && v.fuel !== null;
    toggle(el.fuelRow, 'is-off', !hasFuel);
    if (hasFuel) {
        el.fuel.style.width = `${v.fuel}%`;
        toggle(el.fuel, 'is-low', v.fuel <= 15);
    }

    toggle(el.engine, 'is-off', v.engine > 35);
}

function updateLocation(loc) {
    toggle(el.location, 'is-off', !loc);
    if (!loc) return;

    setText(el.compass, loc.compass);
    setText(el.street, loc.street || '');
    setText(el.zone, loc.zone || '');
}

function updateAnchor(anchor, radar) {
    toggle(hud, 'radar-on', !!radar);
    if (!anchor) return;

    const root = document.documentElement.style;
    root.setProperty('--safe-x', `${anchor.left * 100}vw`);
    root.setProperty('--safe-y', `${(1 - anchor.bottom) * 100}vh`);
    root.setProperty('--map-top', `${anchor.top * 100}vh`);
}

const handlers = {
    config(data) {
        settings.autoHide = { ...settings.autoHide, ...data.autoHide };
        settings.lowThreshold = data.lowThreshold ?? settings.lowThreshold;
        setText(el.unit, data.unit);
    },

    update(data) {
        toggle(hud, 'is-hidden', !data.visible);
        updateAnchor(data.anchor, data.radar);
        updatePlayer(data.player);
        updateVehicle(data.vehicle);
        updateLocation(data.location);
    },
};

window.addEventListener('message', (event) => {
    const { action, data } = event.data || {};
    if (handlers[action]) handlers[action](data);
});
