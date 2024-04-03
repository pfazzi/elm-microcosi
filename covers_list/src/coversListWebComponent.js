import { Elm } from './Main.elm';

class CoversList extends HTMLElement {
    constructor() {
        super();
        this.eventBus = null;
    }

    connectedCallback() {
        const node = document.createElement('div');
        this.appendChild(node);

        const app = Elm.Main.init({
            node: node
        });

        app.ports.publishEvent.subscribe(([eventType, data]) => {
            if (this.eventBus) {
                this.eventBus.publish(eventType, data)
            }
        });
    }

    setEventBus(eventBus) {
        this.eventBus = eventBus;
    }
}

customElements.define('covers-list', CoversList);