const params = new URLSearchParams(location.search);
const elementMode = params.get("main") === "element";

const main = elementMode ? Elm.Simple.Element : Elm.Simple.Application;
const app = main.init({
  node: document.getElementById("root")
});
app.ports.insertIntoBody.subscribe(([id, top, bottom]) => {
  for (let i = 0; i < top; i++) {
    const node = `<div class="top">EXTENSION NODE</div>`;
    document.body.insertAdjacentHTML("afterbegin", node);
  }
  for (let i = 0; i < bottom; i++) {
    const node = `<div class="bottom">EXTENSION NODE</div>`;
    document.body.insertAdjacentHTML("beforeend", node);
  }
  app.ports.done.send(id);
});
app.ports.insertBeforeTarget.subscribe(id => {
  const target = document.querySelector(`#${id} .target`);
  const parent = target.parentElement;
  const el = document.createElement("div");
  el.append("EXTENSION NODE");
  parent.insertBefore(el, target);
  app.ports.done.send(id);
});
app.ports.appendToTarget.subscribe(id => {
  const target = document.querySelector(`#${id} .target`);
  const node = `<div class="ext">EXTENSION NODE</div>`;
  target.insertAdjacentHTML("beforeend", node);
  app.ports.done.send(id);
});
app.ports.removeTarget.subscribe(id => {
  const target = document.querySelector(`#${id} .target`);
  target.remove();
  app.ports.done.send(id);
});
app.ports.wrapTarget.subscribe(id => {
  const target = document.querySelector(`#${id} .target`);
  const parent = target.parentElement;
  const wrapper = document.createElement("font"); // simulate Google Translate
  parent.appendChild(wrapper);
  wrapper.appendChild(target);
  app.ports.done.send(id);
});
app.ports.updateAttribute.subscribe(id => {
  const parent = document.querySelector(`#${id} .target`);
  parent.setAttribute("title", "break"); // simulate Google Translate
  app.ports.done.send(id);
});
