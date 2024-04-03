import App from './App';
import { EventBus } from "./EventBus";

App();

window.eventBus = new EventBus();
window.eventBus.subscribe("covers_list.total_price_changed", console.log)

customElements.whenDefined('covers-list').then(() => {
    const component = document.querySelector('covers-list');
    if (component) {
        component.setEventBus(eventBus);
    }
});

customElements.whenDefined('price-flexibility').then(() => {
    const component = document.querySelector('price-flexibility');
    if (component) {
        component.setEventBus(eventBus);
    }
});
