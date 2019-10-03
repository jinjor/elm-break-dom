const params = new URLSearchParams(location.search);
const elementMode = params.get("main") === "element";

const main = elementMode ? Elm.Simple.Element : Elm.Simple.Application;
const app = main.init({
  node: document.getElementById("root")
});
app.ports.insertIntoBody.subscribe(top => {
  const position = top ? "afterbegin" : "beforeend";
  document.body.insertAdjacentHTML(position, "<div>EXTENSION NODE</div>");
  app.ports.done.send("");
});
app.ports.insertBeforeTarget.subscribe(id => {
  const target = document.querySelector(`#${id} .target`);
  const parent = target.parentElement;
  const el = document.createElement("div");
  el.append("EXTENSION NODE");
  parent.insertBefore(el, target);
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