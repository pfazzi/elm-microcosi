import { Elm } from './Main.elm';

class CoversList extends HTMLElement {
    connectedCallback() {
        const app = Elm.Main.init({
            node: this
        });

        app.ports.sendMsg.subscribe(function(msg) {
            console.log("Messaggio ricevuto da Elm:", msg);
        });
    }
}

customElements.define('covers-list', CoversList);