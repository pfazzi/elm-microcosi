const { MessageConsumerPact } = require("@pact-foundation/pact");
const { JSDOM } = require("jsdom");
const path = require("path");

const pact = new MessageConsumerPact({
    consumer: "price_flexibility",
    provider: "covers_list",
    dir: path.resolve(__dirname, "../pact/pacts"),
    pactfileWriteMode: "update"
});

describe("Pact consumer test", () => {
    it("accepts a total price changed event", async () => {
        // 1. crea DOM finto per Elm
        const dom = new JSDOM("<!DOCTYPE html><html><body></body></html>", {
            runScripts: "dangerously",
            resources: "usable"
        });

        global.window = dom.window;

        // 2. importa e inizializza Elm app minimale con decoder
        const Elm = require("./dist/decoder-app.js").Elm;
        const app = Elm.DecoderApp.init();

        // 3. verifica con Pact che il messaggio sia accettato
        return pact
            .given("a total price was calculated")
            .expectsToReceive("covers_list.total_price_changed")
            .withContent({ totalPrice: 123.45 }) // messaggio JSON da validare
            .withMetadata({ "content-type": "application/json" })
            .verify((message) => {
                return new Promise((resolve, reject) => {
                    app.ports.result.subscribe((msg) => {
                        if (msg.startsWith("OK:")) {
                            resolve("Elm decoder passed");
                        } else {
                            reject("Elm decoder failed: " + msg);
                        }
                    });

                    app.ports.decode.send(message.contents);
                });
            });
    });
});
