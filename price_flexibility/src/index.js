import { Elm } from './Main.elm';

class Index extends HTMLElement {
    connectedCallback() {
        const node = document.createElement('div');
        this.appendChild(node);
        Elm.Main.init({ node: node });
    }
}

window.customElements.define('price-flexibility', Index);
