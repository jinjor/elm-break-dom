const params = new URLSearchParams(location.search);
const main = params.get("main") || "Element";
let enableExtension = params.get("extension") !== "disabled";
const tag = "div";

function debugBody(place) {
  if (false) {
    console.log(place);
    for (let c of document.body.childNodes) {
      console.log("  " + c.tagName, c.created_by_elm);
    }
  }
}

const app = Elm.Simple[main].init({
  node: document.getElementById("root")
});
debugBody("After init");
setTimeout(() => debugBody("After init 2"));
app.ports.event.subscribe(s => {
  if (window.notifyEvent) {
    window.notifyEvent(s);
  }
  app.ports.done.send("");
});
app.ports.insertIntoBody.subscribe(([id, top, bottom]) => {
  if (enableExtension) {
    debugBody("Before insert");
    for (let i = 0; i < top; i++) {
      const node = `<${tag} class="ext top">EXTENSION NODE</${tag}>`;
      document.body.insertAdjacentHTML("afterbegin", node);
    }
    for (let i = 0; i < bottom; i++) {
      const node = `<${tag} class="ext bottom">EXTENSION NODE</${tag}>`;
      document.body.insertAdjacentHTML("beforeend", node);
    }
    debugBody("After insert");
  }
  app.ports.done.send(id);
});
app.ports.insertBeforeTarget.subscribe(id => {
  if (enableExtension) {
    const target = document.querySelector(`#${id} .target`);
    const parent = target.parentElement;
    const el = document.createElement(tag);
    el.classList.add("ext");
    el.append("EXTENSION NODE");
    parent.insertBefore(el, target);
  }
  app.ports.done.send(id);
});
app.ports.appendToTarget.subscribe(id => {
  if (enableExtension) {
    const target = document.querySelector(`#${id} .target`);
    const node = `<${tag} class="ext">EXTENSION NODE</${tag}>`;
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
    parent.insertBefore(wrapper, target);
    wrapper.appendChild(target);
  }
  app.ports.done.send(id);
});
app.ports.updateAttribute.subscribe(([id, key]) => {
  if (enableExtension) {
    const target = document.querySelector(`#${id} .target`);
    target.setAttribute(key, ".ext"); // simulate Google Translate
  }
  app.ports.done.send(id);
});
app.ports.updateProperty.subscribe(([id, key]) => {
  if (enableExtension) {
    const target = document.querySelector(`#${id} .target`);
    target[key] = ".ext";
  }
  app.ports.done.send(id);
});
app.ports.addClass.subscribe(id => {
  if (enableExtension) {
    const target = document.querySelector(`#${id} .target`);
    target.classList.add("ext");
  }
  app.ports.done.send(id);
});
app.ports.updateStyle.subscribe(([id, key]) => {
  if (enableExtension) {
    const target = document.querySelector(`#${id} .target`);
    target.style[key] = ".ext";
  }
  app.ports.done.send(id);
});
app.ports.removeInsertedNode.subscribe(id => {
  debugBody("Before remove");
  for (let el of document.querySelectorAll(`.ext`)) {
    el.remove();
  }
  debugBody("After remove");
  app.ports.done.send(id);
});
app.ports.insertBeforeAndWrapTarget.subscribe(id => {
  if (enableExtension) {
    const target = document.querySelector(`#${id} .target`);
    const parent = target.parentElement;
    const el = document.createElement(tag);
    el.classList.add("ext");
    el.append("EXTENSION NODE");
    parent.insertBefore(el, target);

    const wrapper = document.createElement("font"); // simulate Google Translate
    parent.insertBefore(wrapper, target);
    wrapper.appendChild(target);
  }
  app.ports.done.send(id);
});
app.ports.swap.subscribe(([id, index1, index2]) => {
  if (enableExtension) {
    const target = document.querySelector(`#${id} .target`);
    const children = target.childNodes;
    // console.log(children[index1].tagName, children[index2].tagName);
    const tmp = children[index1];
    target.insertBefore(children[index2], children[index1]);
    target.insertBefore(tmp, children[index2]);
    // console.log(
    //   target.childNodes[index1].tagName,
    //   target.childNodes[index2].tagName
    // );
  }
  app.ports.done.send(id);
});
app.ports.disableExtension.subscribe(id => {
  enableExtension = false;
});
