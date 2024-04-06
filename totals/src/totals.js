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
    }
}

customElements.define('offer-totals', CoversList);