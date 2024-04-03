export class EventBus {
    constructor() {
        this.listeners = {};
    }

    subscribe(eventType, callback) {
        if (!this.listeners[eventType]) {
            this.listeners[eventType] = [];
        }
        this.listeners[eventType].push(callback);
    }

    publish(eventType, data) {
        (this.listeners[eventType] || []).forEach(callback => callback(data, eventType));
    }
}