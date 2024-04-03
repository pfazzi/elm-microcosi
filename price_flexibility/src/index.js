import { Elm } from './Main.elm';

class Index extends HTMLElement {
    constructor() {
        super();
        this.eventBus = null;
    }

    connectedCallback() {
        const node = document.createElement('div');
        this.appendChild(node);
        this.app = Elm.Main.init({ node: node });
    }

    setEventBus(eventBus) {
        this.eventBus = eventBus;

        eventBus.subscribe("covers_list.total_price_changed", eventData => {
            this.app.ports.onEvent.send(eventData);
        });
    }
}

window.customElements.define('price-flexibility', Index);
