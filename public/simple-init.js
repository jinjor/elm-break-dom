const params = new URLSearchParams(location.search);
const main = params.get("main") || "Element";
const enableExtension = params.get("extension") !== "disabled";

const app = Elm.Simple[main].init({
  node: document.getElementById("root")
});
// console.log("After init");
// for (let c of document.body.childNodes) {
//   console.log("  " + c.tagName, c.created_by_elm);
// }
setTimeout(() => {
  // console.log("After init 2");
  // for (let c of document.body.childNodes) {
  //   console.log("  " + c.tagName, c.created_by_elm);
  // }
});
app.ports.event.subscribe(s => {
  if (window.notifyEvent) {
    window.notifyEvent(s);
  }
  app.ports.done.send("");
});
app.ports.insertIntoBody.subscribe(([id, top, bottom]) => {
  if (enableExtension) {
    // console.log("Before insert");
    // for (let c of document.body.childNodes) {
    //   console.log("  " + c.tagName, c.created_by_elm, c.nodeType);
    // }
    for (let i = 0; i < top; i++) {
      const node = `<div class="ext top">EXTENSION NODE</div>`;
      document.body.insertAdjacentHTML("afterbegin", node);
    }
    for (let i = 0; i < bottom; i++) {
      const node = `<div class="ext bottom">EXTENSION NODE</div>`;
      document.body.insertAdjacentHTML("beforeend", node);
    }
    // console.log("After insert");
    // for (let c of document.body.childNodes) {
    //   console.log("  " + c.tagName, c.created_by_elm);
    // }
  }
  app.ports.done.send(id);
});
app.ports.insertBeforeTarget.subscribe(id => {
  if (enableExtension) {
    const target = document.querySelector(`#${id} .target`);
    const parent = target.parentElement;
    const el = document.createElement("div");
    el.classList.add("ext");
    el.append("EXTENSION NODE");
    parent.insertBefore(el, target);
  }
  app.ports.done.send(id);
});
app.ports.appendToTarget.subscribe(id => {
  if (enableExtension) {
    const target = document.querySelector(`#${id} .target`);
    const node = `<div class="ext">EXTENSION NODE</div>`;
    target.insertAdjacentHTML("beforeend", node);
  }
  app.ports.done.send(id);
});
app.ports.removeTarget.subscribe(id => {
  if (enableExtension) {
    const target = document.querySelector(`#${id} .target`);
    target.remove();
  }
  app.ports.done.send(id);
});
app.ports.wrapTarget.subscribe(id => {
  if (enableExtension) {
    const target = document.querySelector(`#${id} .target`);
    const parent = target.parentElement;
    const wrapper = document.createElement("font"); // simulate Google Translate
    parent.appendChild(wrapper);
    wrapper.appendChild(target);
  }
  app.ports.done.send(id);
});
app.ports.updateAttribute.subscribe(id => {
  if (enableExtension) {
    const parent = document.querySelector(`#${id} .target`);
    parent.setAttribute("title", "break"); // simulate Google Translate
  }
  app.ports.done.send(id);
});
app.ports.removeInsertedNode.subscribe(id => {
  // console.log("Before remove");
  // for (let c of document.body.childNodes) {
  //   console.log("  " + c.tagName, c.created_by_elm);
  // }
  for (let el of document.querySelectorAll(`.ext`)) {
    el.remove();
  }
  // console.log("After remove");
  // for (let c of document.body.childNodes) {
  //   console.log("  " + c.tagName, c.created_by_elm);
  // }
  app.ports.done.send(id);
});
