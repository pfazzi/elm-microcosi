const { JSDOM } = require("jsdom");
const Elm = require("./dist/decoder-app.js").Elm;

const dom = new JSDOM("<!DOCTYPE html><div id='elm'></div>", {
    runScripts: "dangerously",
    resources: "usable"
});

const app = Elm.DecoderApp.init();

// Sottoscrivi alla porta di risposta
app.ports.result.subscribe((msg) => {
    console.log("Decoder result:", msg);
});

// Simula invio evento JSON come farebbe covers_list
app.ports.decode.send({ totalPrice: 123.45 });
