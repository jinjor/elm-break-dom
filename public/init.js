const params = new URLSearchParams(location.search);
const elementMode = params.get("main") === "element";
const manualMode = params.get("test") === "manual";

(async () => {
  initElm();
  await new Promise(resolve => setTimeout(resolve, 100));
  runMocha();
})();

function initElm() {
  const main = elementMode
    ? Elm.Extensions.Element
    : Elm.Extensions.Application;
  const app = main.init({
    node: document.getElementById("root")
  });
  app.ports.focusTextarea.subscribe(id => {
    const textarea = document.querySelector(`#${id} textarea`);
    textarea.focus();
    setTimeout(() => {
      textarea.blur();
      app.ports.done.send(id);
    }, 30);
  });
}
function runMocha() {
  mocha.setup("bdd");
  describe("Extentions", function() {
    this.slow(1000);
    let error;
    let successful = true;
    before(function() {
      window.onerror = function(e) {
        error = e;
      };
    });
    describe("Load this page", function() {
      it("should load this page without errors", async function() {
        if (error) {
          throw error;
        }
      });
    });
    describe("First update (for ChromeVox or Viber)", function() {
      it("should safely update dom after load", async function() {
        await new Promise(resolve => setTimeout(resolve, 100)); // wait for inserting ChromeVox
        document.querySelector("#update button").click();
        await new Promise(resolve => setTimeout(resolve, 100));
        if (error) {
          throw error;
        }
      });
    });
    describe("Dark Reader", function() {
      it("should safely update dom after load 1", async function() {
        document.querySelector("#style1 button").click();
        await new Promise(resolve => setTimeout(resolve, 100));
        if (error) {
          throw error;
        }
      });
      it("should safely update dom after load 2", async function() {
        document.querySelector("#style2 button").click();
        await new Promise(resolve => setTimeout(resolve, 100));
        if (error) {
          throw error;
        }
      });
    });
    describe("Grammarly", function() {
      it("should update dom after focusing on textarea 1", async function() {
        document.querySelector("#textarea1 button").click();
        await new Promise(resolve => setTimeout(resolve, 100));
        if (error) {
          throw error;
        }
      });
      it("should update dom after focusing on textarea 2", async function() {
        document.querySelector("#textarea2 button").click();
        await new Promise(resolve => setTimeout(resolve, 100));
        if (error) {
          throw error;
        }
      });
      it("should update dom after focusing on textarea 3", async function() {
        document.querySelector("#textarea3 button").click();
        await new Promise(resolve => setTimeout(resolve, 100));
        if (error) {
          throw error;
        }
        if (document.querySelector("#textarea3 textarea.before")) {
          throw new Error(`found: textarea.before`);
        }
        if (!document.querySelector("#textarea3 textarea.after")) {
          throw new Error("not found: textarea.after");
        }
      });
    });
    afterEach(function() {
      if (error) {
        throw new Error("Unable to continue tests");
      }
      if (this.currentTest.state === "failed") {
        successful = false;
      }
    });
    after(function() {
      scrollTo(0, 0);
      if (window.done) {
        window.done(successful);
      }
    });
  });
  if (!manualMode) {
    mocha.run();
  }
}
