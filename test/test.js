const puppeteer = require("puppeteer");
const assert = require("assert");
const express = require("express");
const fs = require("fs");
const rimraf = require("rimraf");
const chalk = require("chalk");
const pti = require("puppeteer-to-istanbul");
const { mergeCoverageByUrl } = require("./util.js");

const port = 3000;
const headless = process.env.HEADLESS === "false" ? false : true;
const version = process.env.SRC_VERSION;
if (!["Original", "Patched", "Patched-without-extension"].includes(version)) {
  throw new Error("SRC_VERSION must be specified.");
}

rimraf.sync("screenshots");
fs.mkdirSync("screenshots");

describe("Simple", function() {
  this.slow(2000);
  this.timeout(20 * 1000);
  let server;
  let browser;
  let page;
  let error;
  let eventResult;
  let warnings;
  before(async function() {
    const app = express();
    app.use(express.static(`${__dirname}/../public`));
    server = app.listen(port);
    browser = await puppeteer.launch({ headless });
    page = await browser.newPage();
    await page.exposeFunction("notifyEvent", s => {
      eventResult.push(s);
    });
    page.on("console", async msg => {
      const args = await msg.args();
      const values = await Promise.all(
        args.map(arg => arg.executionContext().evaluate(a => a, arg))
      );
      const strings = values
        .filter(v => {
          if (typeof v === "string" && v.startsWith("WARN")) {
            warnings.push(v);
          }
          if (typeof v === "string") {
            return (
              !v.startsWith("INFO") && !v.startsWith("Compiled in DEV mode")
            );
          }
          return true;
        })
        .map(v => chalk.gray(v));
      strings.length && console.log(...strings);
    });
    page.on("pageerror", function(e) {
      error = e;
    });
  });
  beforeEach(async function() {
    error = undefined;
    eventResult = [];
  });
  async function waitForSuccessfulUpdate(page, expectedCount) {
    let ended = false;
    await Promise.race([
      (async () => {
        try {
          await page.waitForSelector(`.count-${expectedCount}`);
        } catch (e) {
          if (!ended) {
            throw e;
          }
        } finally {
          ended = true;
        }
      })(),
      (async () => {
        for (let i = 0; i < 200; i++) {
          await page.waitFor(10);
          if (ended) {
            return;
          }
          if (error) {
            ended = true;
            throw error;
          }
        }
      })()
    ]);
  }
  async function assertEventResult(expected) {
    for (let i = 0; i < 4; i++) {
      if (eventResult.length >= expected.length) {
        break;
      }
      await page.waitFor(50);
    }
    assert.deepEqual(eventResult, expected);
  }

  const html = version === "Original" ? "simple.html" : "simple-patched.html";
  const hasExt = version !== "Patched-without-extension";
  const ext = hasExt ? "enabled" : "disabled";
  async function assertCount(page, selector, n) {
    if (!hasExt && selector.includes(".ext") && n > 0) {
      return;
    }
    assert.equal((await page.$$(selector)).length, n);
  }
  describe(version, function() {
    let coverages = [];
    before(function() {
      warnings = [];
    });
    if (version === "Patched") {
      after(async function() {
        pti.write(mergeCoverageByUrl(coverages));
      });
    }
    for (let main of ["Application", "Document", "Element"]) {
      describe(main, function() {
        if (version === "Patched" && main === "Application") {
          before(async function() {
            rimraf.sync(".nyc_output");
            fs.mkdirSync(".nyc_output");
            rimraf.sync("public/coverage");
            fs.mkdirSync("public/coverage");
            console.log(chalk.cyan("[start coverage]"));
            await page.coverage.startJSCoverage({
              resetOnNavigation: false
            });
          });
          after(async function() {
            this.timeout(30 * 1000);
            console.log(chalk.cyan("[stop coverage]"));
            const jsCoverage = await page.coverage.stopJSCoverage();
            coverages.push(jsCoverage);
          });
        }
        before(async function() {
          await page.goto(
            `http://localhost:${port}/${html}?main=${main}&extension=${ext}`
          );
          await page.waitFor(50);
        });
        beforeEach(async function() {
          const start = Date.now();
          await page.reload();
          if (Date.now() - start > 1000) {
            console.log(`Reload slowing down most likely due to JS coverage.`);
          }
          try {
            await page.waitForSelector("ul", { timeout: 1800 });
          } catch (e) {
            await page.$eval("body", body => console.log(body.innerHTML));
            throw e;
          }
        });
        describe("Insert into <body>", function() {
          it("at (top = 0, bottom = 0)", async function() {
            await page.click("#insert-into-body1 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "body > .ext.top", 0);
            await assertCount(page, "body > .ext.bottom", 0);

            await page.click("#insert-into-body1 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
          });
          it("at (top = 0, bottom = 1)", async function() {
            await page.click("#insert-into-body2 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "body > .ext.top", 0);
            await assertCount(page, "body > .ext.bottom", 1);

            await page.click("#insert-into-body2 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
          });
          it("at (top = 0, bottom = 2)", async function() {
            await page.click("#insert-into-body3 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "body > .ext.top", 0);
            await assertCount(page, "body > .ext.bottom", 2);

            await page.click("#insert-into-body3 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
          });
          it("at (top = 1, bottom = 0)", async function() {
            await page.click("#insert-into-body4 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "body > .ext.top", 1);
            await assertCount(page, "body > .ext.bottom", 0);

            await page.click("#insert-into-body4 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
          });
          it("at (top = 1, bottom = 1)", async function() {
            await page.click("#insert-into-body5 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "body > .ext.top", 1);
            await assertCount(page, "body > .ext.bottom", 1);

            await page.click("#insert-into-body5 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
          });
          it("at (top = 1, bottom = 2)", async function() {
            await page.click("#insert-into-body6 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "body > .ext.top", 1);
            await assertCount(page, "body > .ext.bottom", 2);

            await page.click("#insert-into-body6 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
          });
          it("at (top = 2, bottom = 0)", async function() {
            await page.click("#insert-into-body7 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "body > .ext.top", 2);
            await assertCount(page, "body > .ext.bottom", 0);

            await page.click("#insert-into-body7 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
          });
          it("at (top = 2, bottom = 1)", async function() {
            await page.click("#insert-into-body8 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "body > .ext.top", 2);
            await assertCount(page, "body > .ext.bottom", 1);

            await page.click("#insert-into-body8 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
          });
        });
        describe("Insert before target element", function() {
          it("...and update target's grand child", async function() {
            await page.click("#insert1 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's child", async function() {
            await page.click("#insert2 button.break");
            await waitForSuccessfulUpdate(page, 1);
            assert.equal(
              await page.$eval("#insert2 .target", el => el.textContent),
              "after"
            );
          });
          it("...and update target's next element", async function() {
            await page.click("#insert3 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's class", async function() {
            await page.click("#insert4 button.break");
            await waitForSuccessfulUpdate(page, 1);
            assert.equal((await page.$$("#insert4 .target.before")).length, 0);
            assert.equal((await page.$$("#insert4 .target.after")).length, 1);
          });
          it("...and update target's previous element", async function() {
            await page.click("#insert5 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and replace previous element (text -> div)", async function() {
            await page.click("#insert6 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#insert6 .e1")).length, 1);
          });
          it("...and replace previous element (div -> text)", async function() {
            await page.click("#insert7 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#insert7 .e1")).length, 0);
          });
          it("...and remove target", async function() {
            await page.click("#insert8 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and insert text before target", async function() {
            await page.click("#insert9 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and insert <div> before target", async function() {
            await page.click("#insert10 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#insert10 .e1")).length, 1);
          });
          it("...and insert <a> before target", async function() {
            await page.click("#insert11 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#insert11 .e1")).length, 1);
          });
          it("...and replace target with <a>", async function() {
            await page.click("#insert12 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#insert12 .e1")).length, 1);
          });
          it("...and remove target's previous <div>", async function() {
            await page.click("#insert13 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#insert13 .e1")).length, 0);
          });
          it("...and remove target's previous <a>", async function() {
            await page.click("#insert14 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#insert14 .e1")).length, 0);
          });
          it("...and remove target's previous text", async function() {
            await page.click("#insert15 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and insert text after target", async function() {
            await page.click("#insert16 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and insert <div> after target", async function() {
            await page.click("#insert17 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#insert17 .e1")).length, 1);
          });
          it("...and insert <a> after target", async function() {
            await page.click("#insert18 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#insert18 .e1")).length, 1);
          });
          it("...and remove <div> after target", async function() {
            await page.click("#insert19 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#insert19 .e1")).length, 0);
          });
          it("...and remove <a> after target", async function() {
            await page.click("#insert20 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#insert20 .e1")).length, 0);
          });
          it("...and remove text after target", async function() {
            await page.click("#insert21 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("22-28", async function() {
            for (let i = 22; i <= 28; i++) {
              await page.click(`#insert${i} button`);
              await waitForSuccessfulUpdate(page, 1);
            }
          });
        });
        describe("Append to target element", function() {
          it("...and update target's attribute", async function() {
            await page.click("#append1 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#append1 .ext", 1);
            await assertCount(page, "#append1 .target.before", 0);
            await assertCount(page, "#append1 .target.after", 1);

            await page.click("#append1 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("...and update target's child", async function() {
            await page.click("#append2 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#append2 .ext", 1);

            await page.click("#append2 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("...and insert text into target", async function() {
            await page.click("#append3 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#append3 .ext", 1);

            await page.click("#append3 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("...and insert <div> into target", async function() {
            await page.click("#append4 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#append4 .ext", 1);
            await assertCount(page, "#append4 .e1", 1);

            await page.click("#append4 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("...and insert <a> into target", async function() {
            await page.click("#append5 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#append5 .ext", 1);
            await assertCount(page, "#append5 .e1", 1);

            await page.click("#append5 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("...and remove text from target", async function() {
            await page.click("#append6 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#append6 .ext", 1);

            await page.click("#append6 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("...and remove <div> from target", async function() {
            await page.click("#append7 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#append7 .ext", 1);
            await assertCount(page, "#append7 .e1", 0);

            await page.click("#append7 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("...and remove <a> from target", async function() {
            await page.click("#append8 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#append8 .ext", 1);
            await assertCount(page, "#append8 .e1", 0);

            await page.click("#append8 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("...and remove 2 texts from target", async function() {
            await page.click("#append9 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#append9 .ext", 1);

            await page.click("#append9 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("...and remove 2 <div>s from target", async function() {
            await page.click("#append10 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#append10 .ext", 1);
            await assertCount(page, "#append10 .e1", 0);
            await assertCount(page, "#append10 .e2", 0);

            await page.click("#append10 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("...and replace target with text", async function() {
            await page.click("#append11 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#append11 .target", 0);
            await assertCount(page, "#append11 .ext", 0);

            await page.click("#append11 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("...and remove target", async function() {
            await page.click("#append12 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#append12 .target", 0);
            await assertCount(page, "#append12 .ext", 0);

            await page.click("#append12 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
        });
        describe("Remove target element", function() {
          it("...and update target's grand child", async function() {
            await page.click("#remove1 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's child", async function() {
            await page.click("#remove2 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's next element", async function() {
            await page.click("#remove3 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's class", async function() {
            await page.click("#remove4 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's previous element", async function() {
            await page.click("#remove5 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
        });
        describe("Wrap target element", function() {
          it("...and update target's child", async function() {
            await page.click("#wrap1 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's class", async function() {
            await page.click("#wrap2 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's next element", async function() {
            await page.click("#wrap3 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's previous element", async function() {
            await page.click("#wrap4 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's child (same tag)", async function() {
            await page.click("#wrap5 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's class (same tag)", async function() {
            await page.click("#wrap6 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#wrap6 .target.before")).length, 0);
            assert.equal((await page.$$("#wrap6 .target.after")).length, 1);
          });
          it("...and update target's next element (same tag)", async function() {
            await page.click("#wrap7 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's previous element (same tag)", async function() {
            await page.click("#wrap8 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and replace target with text", async function() {
            await page.click("#wrap9 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#wrap9 .target")).length, 0);
          });
          it("...and replace target with <a>", async function() {
            await page.click("#wrap10 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#wrap10 .target")).length, 0);
            assert.equal((await page.$$("#wrap10 .e1")).length, 1);
          });
          it("...and replace target with <font> (same tag)", async function() {
            await page.click("#wrap11 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#wrap11 .target")).length, 0);
            assert.equal((await page.$$("#wrap11 .e1")).length, 1);
          });
          it("...and remove target", async function() {
            await page.click("#wrap12 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#wrap12 .target")).length, 0);
          });
          it("...and replace with 2 text nodes", async function() {
            await page.click("#wrap13 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#wrap13 .target")).length, 0);
          });
          it("...and replace with 2 <a> nodes", async function() {
            await page.click("#wrap14 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#wrap14 .target")).length, 0);
            assert.equal((await page.$$("#wrap14 .e1")).length, 1);
            assert.equal((await page.$$("#wrap14 .e2")).length, 1);
          });
          it("...and insert <a> after target", async function() {
            await page.click("#wrap15 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#wrap15 .target")).length, 1);
            assert.equal((await page.$$("#wrap15 .e1")).length, 0);
            assert.equal((await page.$$("#wrap15 .e2")).length, 1);
            assert.equal((await page.$$("#wrap15 .e3")).length, 1);
          });
          it("...and insert <a> before target", async function() {
            await page.click("#wrap16 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#wrap16 .target")).length, 1);
            assert.equal((await page.$$("#wrap16 .e1")).length, 0);
            assert.equal((await page.$$("#wrap16 .e2")).length, 1);
            assert.equal((await page.$$("#wrap16 .e3")).length, 1);
          });
          it("...and insert <font> before target", async function() {
            await page.click("#wrap17 button.break");
            await waitForSuccessfulUpdate(page, 1);

            assert.equal((await page.$$("#wrap17 .target")).length, 1);
            assert.equal((await page.$$("#wrap17 .e1")).length, 0);
            assert.equal((await page.$$("#wrap17 .e2")).length, 1);
            assert.equal((await page.$$("#wrap17 .e3")).length, 1);
          });
        });
        describe("Update target attribute", function() {
          it("...and update target and it's child 1", async function() {
            await page.click("#update-attribute1 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(
              page,
              `#update-attribute1 .target[title=".ext"]`,
              1
            );
          });
          it("...and update target and it's child 2", async function() {
            await page.click("#update-attribute2 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(
              page,
              `#update-attribute2 .target[title=".ext"]`,
              1
            );
          });
          it("...and update target's attribute", async function() {
            await page.click("#update-attribute3 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(
              page,
              `#update-attribute3 .target[title=".ext"]`,
              0
            );
          });
          it("...and update target and it's child (use `attribute`)", async function() {
            await page.click("#update-attribute4 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(
              page,
              `#update-attribute4 .target[title=".ext"]`,
              1
            );
          });
          it("...and update target's attribute (use `attribute`)", async function() {
            await page.click("#update-attribute5 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(
              page,
              `#update-attribute5 .target[title=".ext"]`,
              0
            );
          });
          it("...and update target's attribute (add attribute)", async function() {
            await page.click("#update-attribute6 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(
              page,
              `#update-attribute6 .target[title=".ext"]`,
              0
            );
          });
          it("...and update target's attribute (remove attribute)", async function() {
            await page.click("#update-attribute7 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(
              page,
              `#update-attribute7 .target[title=".ext"]`,
              0
            );
          });
          it("...and update target and it's child (update class)", async function() {
            await page.click("#update-attribute8 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, `#update-attribute8 .e1`, 1);
          });
          it("...and update target and it's child (update data-xxx)", async function() {
            await page.click("#update-attribute9 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, `#update-attribute9 .e1`, 1);
            await assertCount(
              page,
              `#update-attribute9 .target[data-xxx=".ext"]`,
              1
            );
          });
        });
        describe("Update target property", function() {
          it("...and update target and it's child 1", async function() {
            await page.click("#update-property1 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target and it's child 2", async function() {
            await page.click("#update-property2 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's property", async function() {
            await page.click("#update-property3 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target and it's child (use `property`)", async function() {
            await page.click("#update-property4 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's property (use `property`)", async function() {
            await page.click("#update-property5 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's property (add property)", async function() {
            await page.click("#update-property6 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target's property (remove property)", async function() {
            await page.click("#update-property7 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target and it's child (update class)", async function() {
            await page.click("#update-property8 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, `#update-property8 .e1`, 1);
          });
        });
        describe("Add class", function() {
          it("...and update target and it's child 1", async function() {
            await page.click("#add-class1 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update target and it's child 2", async function() {
            await page.click("#add-class2 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
        });
        describe("Update style", function() {
          it("...and update class and it's child", async function() {
            await page.click("#update-style1 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and update another style and it's child", async function() {
            await page.click("#update-style2 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and same style and it's child", async function() {
            await page.click("#update-style3 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and add same style and it's child", async function() {
            await page.click("#update-style4 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("...and remove same style and it's child", async function() {
            await page.click("#update-style5 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
        });
        describe("Events", function() {
          it("insert before target, update target's child, event from target", async function() {
            await page.click("#event1 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event1 .button");
            await assertEventResult(["a"]);

            await page.click("#event1 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's child, event from target (with Html.Attributes.map)", async function() {
            await page.click("#event2 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event2 .button");
            await assertEventResult(["a"]);

            await page.click("#event2 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's child, event from target (with Html.map)", async function() {
            await page.click("#event3 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event3 .button");
            await assertEventResult(["a"]);

            await page.click("#event3 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's event handler, event from target", async function() {
            await page.click("#event4 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event4 .button");
            await assertEventResult(["after"]);

            await page.click("#event4 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's event handler, event from target (with Html.Attributes.map)", async function() {
            await page.click("#event5 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event5 .button");
            await assertEventResult(["after"]);

            await page.click("#event5 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's event handler, event from target (with Html.map)", async function() {
            await page.click("#event6 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event6 .button");
            await assertEventResult(["after"]);

            await page.click("#event6 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's event handler, event from target (with Html.Attributes.map, lambda)", async function() {
            await page.click("#event7 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event7 .button");
            await assertEventResult(["after"]);

            await page.click("#event7 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's event handler, event from target (with Html.map, lambda)", async function() {
            await page.click("#event8 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event8 .button");
            await assertEventResult(["after"]);

            await page.click("#event8 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          async function test3Buttons(selector) {
            await page.click(`${selector} .button.prev`);
            await assertEventResult(["prev"]);
            await page.click(`${selector} .button.target`);
            await assertEventResult(["prev", "target"]);
            await page.click(`${selector} .button.next`);
            await assertEventResult(["prev", "target", "next"]);
          }
          it("insert before target, update target's parent, event around target", async function() {
            await page.click("#event9 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await test3Buttons("#event9");

            await page.click("#event9 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target and siblings, event around target", async function() {
            await page.click("#event10 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await test3Buttons("#event10");

            await page.click("#event10 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's parent, event around target (keyed nodes)", async function() {
            await page.click("#event11 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await test3Buttons("#event11");

            await page.click("#event11 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target and siblings, event around target (keyed nodes)", async function() {
            await page.click("#event12 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await test3Buttons("#event12");

            await page.click("#event12 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's parent, event around target (lazy lambda)", async function() {
            await page.click("#event13 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await test3Buttons("#event13");

            await page.click("#event13 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target and siblings, event around target (lazy children)", async function() {
            await page.click("#event14 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await test3Buttons("#event14");

            await page.click("#event14 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("wrap target, update target's event handler, event from target (with Html.Attributes.map)", async function() {
            await page.click("#event15 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event15 .button");
            await assertEventResult(["after"]);
          });
          it("wrap target, update target's event handler, event from target (with Html.Attributes.map)", async function() {
            await page.click("#event16 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event16 .button");
            await assertEventResult(["after"]);
          });
          it("wrap target, update target's event handler, event from target (with Html.Attributes.map, lambda)", async function() {
            await page.click("#event17 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event17 .button");
            await assertEventResult(["after"]);
          });
          it("wrap target, update target's event handler, event from target (with Html.Attributes.map, lambda)", async function() {
            await page.click("#event18 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event18 .button");
            await assertEventResult(["after"]);
          });
          it("remove target, update target's event handler, event from target", async function() {
            await page.click("#event19 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event19 .button");
            await assertEventResult(["after"]);
          });
          it("insert before target, update target's event handler, (no) event from target", async function() {
            await page.click("#event20 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event20 .button");
            await assertEventResult([]);

            await page.click("#event20 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's event handler, NoOp from target", async function() {
            await page.click("#event21 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event21 .button");
            await assertEventResult([]);

            await page.click("#event21 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's event handler, new event from target", async function() {
            await page.click("#event22 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event22 .button");
            await assertEventResult(["a"]);

            await page.click("#event22 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's event handler, nested event from target", async function() {
            await page.click("#event23 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event23 .button");
            await assertEventResult(["after"]);

            await page.click("#event23 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's event handler, nested event from target (add nest)", async function() {
            await page.click("#event24 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event24 .button");
            await assertEventResult(["b"]);

            await page.click("#event24 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's event handler, nested event from target (remove nest)", async function() {
            await page.click("#event25 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event25 .button");
            await assertEventResult(["b"]);

            await page.click("#event25 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's event handler, nested event from target (double)", async function() {
            await page.click("#event26 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event26 .button");
            await assertEventResult(["1"]);

            await page.click("#event26 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's event handler, nested event from target (double, add nest)", async function() {
            await page.click("#event27 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event27 .button");
            await assertEventResult(["1"]);

            await page.click("#event27 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target, update target's event handler, nested event from target (double, remove nest)", async function() {
            await page.click("#event28 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#event28 .button");
            await assertEventResult(["1"]);

            await page.click("#event28 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
        });
        describe("Keyed nodes", function() {
          it("insert before target and update its attribute", async function() {
            await page.click("#keyed1 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#keyed1 .e0", 0);
            await assertCount(page, "#keyed1 .e1", 1);

            await page.click("#keyed1 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target and update its key", async function() {
            await page.click("#keyed2 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#keyed2 .e0", 0);
            await assertCount(page, "#keyed2 .e1", 1);

            await page.click("#keyed2 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target and update its key, attribute and child", async function() {
            await page.click("#keyed3 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#keyed3 .e0", 0);
            await assertCount(page, "#keyed3 .e1", 1);

            await page.click("#keyed3 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target (keyed node's parent) and update its attribute", async function() {
            await page.click("#keyed4 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#keyed4 .e0", 0);
            await assertCount(page, "#keyed4 .e1", 1);

            await page.click("#keyed4 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("wrap target (keyed node's parent) and update its attribute", async function() {
            await page.click("#keyed5 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#keyed5 .e0", 0);
            await assertCount(page, "#keyed5 .e1", 1);
          });
          it("update target's attribute and update its attribute and child", async function() {
            await page.click("#keyed6 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#keyed6 .e0", 0);
            await assertCount(page, "#keyed6 .e1", 1);
            await assertCount(page, `#keyed6 .target[title=".ext"]`, 1);
          });
          it("update target's attribute and update its parent's attribute", async function() {
            await page.click("#keyed7 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#keyed7 .e0", 0);
            await assertCount(page, "#keyed7 .e1", 1);
            await assertCount(page, `#keyed7 .target[title=".ext"]`, 1);
          });
          it("update target's attribute and update its key and child", async function() {
            await page.click("#keyed8 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#keyed8 .e0", 0);
            await assertCount(page, "#keyed8 .e1", 1);
            await assertCount(page, `#keyed8 .target`, 1);
          });
          it("update target's attribute and remove it", async function() {
            await page.click("#keyed9 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed9 .target`, 0);
          });
          it("update target's attribute and sort (target = first node)", async function() {
            await page.click("#keyed10 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed10 .target.e1[title=".ext"]`, 1);
            await assertCount(page, `#keyed10 .e2`, 1);
            await assertCount(page, `#keyed10 .e2[title=".ext"]`, 0);
          });
          it("update target's attribute and sort (target = second node)", async function() {
            await page.click("#keyed11 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed11 .target.e2[title=".ext"]`, 1);
            await assertCount(page, `#keyed11 .e1`, 1);
            await assertCount(page, `#keyed11 .e1[title=".ext"]`, 0);
          });
          it("insert before target and sort (target = first node)", async function() {
            await page.click("#keyed12 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed12 .target.e1`, 1);
            await assertCount(page, `#keyed12 .e2`, 1);
            await assertCount(page, `#keyed12 .target.e2`, 0);

            await page.click("#keyed12 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target and sort (target = second node)", async function() {
            await page.click("#keyed13 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed13 .target.e2`, 1);
            await assertCount(page, `#keyed13 .e1`, 1);
            await assertCount(page, `#keyed13 .target.e1`, 0);

            await page.click("#keyed13 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target and append node", async function() {
            await page.click("#keyed14 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed14 .target.e1`, 1);
            await assertCount(page, `#keyed14 .e2`, 1);
            await assertCount(page, `#keyed14 .target.e2`, 0);

            await page.click("#keyed14 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target and prepend node", async function() {
            await page.click("#keyed15 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed15 .target.e1`, 1);
            await assertCount(page, `#keyed15 .e2`, 1);
            await assertCount(page, `#keyed15 .target.e2`, 0);

            await page.click("#keyed15 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target and remove target", async function() {
            await page.click("#keyed16 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed16 .target`, 0);

            await page.click("#keyed16 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("append to target and update child text", async function() {
            await page.click("#keyed17 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed17 .target`, 1);

            await page.click("#keyed17 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("append to target and update key and child text", async function() {
            await page.click("#keyed18 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed18 .target`, 1);

            await page.click("#keyed18 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("append to target and remove child text", async function() {
            await page.click("#keyed19 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed19 .target`, 1);

            await page.click("#keyed19 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("append to target and append text", async function() {
            await page.click("#keyed20 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed20 .target`, 1);

            await page.click("#keyed20 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("append to target and update child <div>", async function() {
            await page.click("#keyed21 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed21 .target`, 1);
            await assertCount(page, `#keyed21 .e0`, 0);
            await assertCount(page, `#keyed21 .e1`, 1);

            await page.click("#keyed21 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("append to target and update key and child <div>", async function() {
            await page.click("#keyed22 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed22 .target`, 1);
            await assertCount(page, `#keyed22 .e0`, 0);
            await assertCount(page, `#keyed22 .e1`, 1);

            await page.click("#keyed22 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("append to target and remove child <div>", async function() {
            await page.click("#keyed23 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed23 .target`, 1);
            await assertCount(page, `#keyed23 .e1`, 0);

            await page.click("#keyed23 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("append to target and append <div>", async function() {
            await page.click("#keyed24 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, `#keyed24 .target`, 1);
            await assertCount(page, `#keyed24 .e1`, 1);

            await page.click("#keyed24 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("append to target and update tag name", async function() {
            await page.click("#keyed25 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, "#keyed25 .target", 1);
            await assertCount(page, "#keyed25 .e0", 0);
            await assertCount(page, "#keyed25 .e1", 1);

            await page.click("#keyed25 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("append to target and add key", async function() {
            await page.click("#keyed26 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, "#keyed26 .target", 1);
            await assertCount(page, "#keyed26 .e1", 0);
            await assertCount(page, "#keyed26 .e2", 1);

            await page.click("#keyed26 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("append to target and remove key", async function() {
            await page.click("#keyed27 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, "#keyed27 .target", 1);
            await assertCount(page, "#keyed27 .e1", 0);
            await assertCount(page, "#keyed27 .e2", 1);

            await page.click("#keyed27 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target and update tag name", async function() {
            await page.click("#keyed28 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, "#keyed28 .target", 1);
            await assertCount(page, "#keyed28 .e0", 0);
            await assertCount(page, "#keyed28 .e1", 1);

            await page.click("#keyed28 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target and add key", async function() {
            await page.click("#keyed29 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, "#keyed29 .target", 1);
            await assertCount(page, "#keyed29 .e1", 0);
            await assertCount(page, "#keyed29 .e2", 1);

            await page.click("#keyed29 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target and remove key", async function() {
            await page.click("#keyed30 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, "#keyed30 .target", 1);
            await assertCount(page, "#keyed30 .e1", 0);
            await assertCount(page, "#keyed30 .e2", 1);

            await page.click("#keyed30 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
        });
        describe("Lazy nodes", function() {
          it("insert before target and update its lazy child (text)", async function() {
            await page.click("#lazy1 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy1 .target", 1);

            await page.click("#lazy1 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("remove target and update its lazy child (text)", async function() {
            await page.click("#lazy2 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy2 .target", 1);
          });
          it("wrap target and update its lazy child (text)", async function() {
            await page.click("#lazy3 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy3 .target", 1);
          });
          it("append to target and update its lazy child (text)", async function() {
            await page.click("#lazy4 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy4 .target", 1);

            await page.click("#lazy4 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target and update its lazy child (div)", async function() {
            await page.click("#lazy5 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy5 .target", 1);

            await page.click("#lazy5 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("remove target and update its lazy child (div)", async function() {
            await page.click("#lazy6 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy6 .target", 1);
          });
          it("wrap target and update its lazy child (div)", async function() {
            await page.click("#lazy7 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy7 .target", 1);
          });
          it("append to target and update its lazy child (div)", async function() {
            await page.click("#lazy8 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy8 .target", 1);

            await page.click("#lazy8 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before target and update its lazy child (directly use text)", async function() {
            await page.click("#lazy9 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy9 .target", 1);

            await page.click("#lazy9 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("remove target and update its lazy child (directly use text)", async function() {
            await page.click("#lazy10 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy10 .target", 1);
          });
          it("wrap target and update its lazy child (directly use text)", async function() {
            await page.click("#lazy11 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy11 .target", 1);
          });
          it("append to target and update its lazy child (directly use text)", async function() {
            await page.click("#lazy12 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy12 .target", 1);

            await page.click("#lazy12 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });

          it("insert before target and update its lazy child (use lambda)", async function() {
            await page.click("#lazy13 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy13 .target", 1);

            await page.click("#lazy13 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("remove target and update its lazy child (use lambda)", async function() {
            await page.click("#lazy14 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy14 .target", 1);
          });
          it("wrap target and update its lazy child (use lambda)", async function() {
            await page.click("#lazy15 button.break");
            await waitForSuccessfulUpdate(page, 1);

            await assertCount(page, "#lazy15 .target", 1);
          });
          it("append to target and update its lazy child (use lambda)", async function() {
            await page.click("#lazy16 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, "#lazy16 .target", 1);

            await page.click("#lazy16 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("insert before lazy target and update its child (text)", async function() {
            await page.click("#lazy17 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, "#lazy17 .target", 1);

            await page.click("#lazy17 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
          it("remove lazy target and update its child (text)", async function() {
            await page.click("#lazy18 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, "#lazy18 .target", 1);
          });
          it("wrap lazy target and update its child (text)", async function() {
            await page.click("#lazy19 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, "#lazy19 .target", 1);
          });
          it("append to lazy target and update its child (text)", async function() {
            await page.click("#lazy20 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, "#lazy20 .target", 1);

            await page.click("#lazy20 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);
          });
        });
        if (main === "Application") {
          describe("Routing", function() {
            async function testRouting(selector) {
              await page.click(`${selector} a.target`);
              await waitForSuccessfulUpdate(page, 1);
              await assertCount(page, `${selector} .e0`, 0);
              await assertCount(page, `${selector} .e1`, 1);

              await page.click(`${selector} a.target`);
              await waitForSuccessfulUpdate(page, 2);
              await assertCount(page, `${selector} .e1`, 0);
              await assertCount(page, `${selector} .e2`, 1);

              await page.click(`${selector} button.remove-inserted-node`);
              await waitForSuccessfulUpdate(page, 3);
              await assertCount(page, ".ext", 0);
            }
            it("insert before target and update its attribute", async function() {
              await testRouting("#route1");
            });
            it("insert before target and update previous node", async function() {
              await testRouting("#route2");
            });
            it("insert before target and update next node", async function() {
              await testRouting("#route3");
            });
            it("insert before target and update its parent", async function() {
              await testRouting("#route4");
            });
            it("remove target and update its child", async function() {
              await testRouting("#route5");
            });
            it("wrap target and update its child", async function() {
              await testRouting("#route6");
            });
            it("append to target and update its child", async function() {
              await testRouting("#route7");
            });
            it("append to target and insert child", async function() {
              await testRouting("#route8");
            });
            it("append to target and remove child", async function() {
              await testRouting("#route9");
            });
            it("insert into body and update target", async function() {
              await testRouting("#route10");
            });
          });
        }
        describe("Edge", function() {
          it("cover more lines", async function() {
            await page.click(`#edge1 button.break`);
            await waitForSuccessfulUpdate(page, 1);

            await page.click("#edge1 button.remove-inserted-node");
            await waitForSuccessfulUpdate(page, 2);
            await assertCount(page, ".ext", 0);

            await page.click(`#edge1 .e1`);
            await page.click(`#edge1 .e2`);
            await page.click(`#edge1 .e3`);
            await page.click(`#edge1 .e4`);
            await page.click(`#edge1 .e5`);
            await page.click(`#edge1 .e6`);
            await page.click(`#edge1 .e7`);
            await page.click(`#edge1 .e8`);
            await assertEventResult(["1", "2", "3", "4"]);
            await page.click(`#edge1 .e1`);
            await page.click(`#edge1 .e2`);
            await page.click(`#edge1 .e3`);
            await page.click(`#edge1 .e4`);
            await assertEventResult(["1", "2", "3", "4", "1", "2", "3", "4"]);
          });
        });
        if (main === "Application" || main === "Document") {
          async function testBoundary(selector, contentsExists) {
            await page.click(`${selector} button.break`);
            await waitForSuccessfulUpdate(page, 1);
            await assertCount(page, ".ext", 1);
            if (contentsExists) {
              await page.click(`${selector} button.remove-inserted-node`);
              await waitForSuccessfulUpdate(page, 2);
              await assertCount(page, ".ext", 0);
            }
          }
          describe("Boundary", function() {
            it("prepend .ext to body and prepend text", async function() {
              await testBoundary("#boundary1", true);
            });
            it("prepend .ext to body and prepend element", async function() {
              await testBoundary("#boundary2", true);
            });
            it("prepend .ext to body and append text", async function() {
              await testBoundary("#boundary3", true);
            });
            it("prepend .ext to body and append element", async function() {
              await testBoundary("#boundary4", true);
            });
            it("prepend .ext to body and replace contents with text", async function() {
              await testBoundary("#boundary5", false);
            });
            it("prepend .ext to body and remove contents", async function() {
              await testBoundary("#boundary6", false);
            });
            it("append .ext to body and prepend text", async function() {
              await testBoundary("#boundary7", true);
            });
            it("append .ext to body and prepend element", async function() {
              await testBoundary("#boundary8", true);
            });
            it("append .ext to body and append text", async function() {
              await testBoundary("#boundary9", true);
            });
            it("append .ext to body and append element", async function() {
              await testBoundary("#boundary10", true);
            });
            it("append .ext to body and replace contents with text", async function() {
              await testBoundary("#boundary11", false);
            });
            it("append .ext to body and remove contents", async function() {
              await testBoundary("#boundary12", false);
            });
          });
        }
        describe("Insert and Wrap", function() {
          it("[target]", async function() {
            await page.click("#insert-wrap1 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("[text, target]", async function() {
            await page.click("#insert-wrap2 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("[div, target]", async function() {
            await page.click("#insert-wrap3 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("[p, target]", async function() {
            await page.click("#insert-wrap4 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("[target] -> []", async function() {
            await page.click("#insert-wrap5 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("[target] -> [text]", async function() {
            await page.click("#insert-wrap6 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("[target] -> [div]", async function() {
            await page.click("#insert-wrap7 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("[target] -> [p]", async function() {
            await page.click("#insert-wrap8 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("[target] -> [text, text]", async function() {
            await page.click("#insert-wrap9 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("[target] -> [div, div]", async function() {
            await page.click("#insert-wrap10 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
          it("[target] -> [p, p]", async function() {
            await page.click("#insert-wrap11 button.break");
            await waitForSuccessfulUpdate(page, 1);
          });
        });
        describe.only("Swap", function() {
          async function assertChildrenCount(selector, expectedCount) {
            const count = await page.$eval(
              `${selector} .target`,
              e => e.childNodes.length
            );
            assert.equal(count, expectedCount);
          }
          it("swap texts and update second", async function() {
            await page.click("#swap1 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap1", 2);
          });
          it("swap texts and update first", async function() {
            await page.click("#swap2 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap2", 2);
          });
          it("swap [text,div] and update", async function() {
            await page.click("#swap3 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap3", 2);
          });
          it("swap [div,text] and update", async function() {
            await page.click("#swap4 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap4", 2);
          });
          it("swap [text,span] and update", async function() {
            await page.click("#swap5 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap5", 2);
          });
          it("swap [text,text] and remove both", async function() {
            await page.click("#swap6 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap6", 0);
          });
          it("swap [div,div] and remove both", async function() {
            await page.click("#swap7 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap7", 0);
          });
          it("swap [div,text] and swap them", async function() {
            await page.click("#swap8 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap8", 2);
          });
          it("swap [text,div] and swap them", async function() {
            await page.click("#swap9 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap9", 2);
          });
          it("swap [div,span] and swap them", async function() {
            await page.click("#swap10 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap10", 2);
          });
          it("swap [div,div] and swap [style, class]", async function() {
            await page.click("#swap11 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap11", 2);
          });
          it("swap [div,div] and swap [class, style]", async function() {
            await page.click("#swap12 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap12", 2);
          });
          it("swap keyed texts and update second", async function() {
            await page.click("#swap13 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap13", 2);
          });
          it("swap keyed texts and update first", async function() {
            await page.click("#swap14 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap14", 2);
          });
          it("swap keyed [div, text] and update", async function() {
            await page.click("#swap15 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap15", 2);
          });
          it("swap keyed [text, div] and update", async function() {
            await page.click("#swap16 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap16", 2);
          });
          it("swap keyed [div, text] and update", async function() {
            await page.click("#swap17 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap17", 2);
          });
          it("swap keyed [span, div] and update", async function() {
            await page.click("#swap18 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap18", 2);
          });
          it("swap keyed [div(empty), div] and update", async function() {
            await page.click("#swap19 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap19", 2);
          });
          it("swap keyed text and update first key", async function() {
            await page.click("#swap20 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap20", 2);
          });
          it("swap keyed text and update second key", async function() {
            await page.click("#swap21 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap21", 2);
          });
          it("swap keyed [div, text] and update first key", async function() {
            await page.click("#swap22 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap22", 2);
          });
          it("swap keyed [text, div] and update second key", async function() {
            await page.click("#swap23 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap23", 2);
          });
          it("swap mapped [text, div] and update", async function() {
            await page.click("#swap24 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap24", 2);
          });
          it("swap mapped [div, text] and update", async function() {
            await page.click("#swap25 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap25", 2);
          });
          it("swap keyed & mapped [text, div] and update", async function() {
            await page.click("#swap26 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap26", 2);
          });
          it("swap keyed & mapped [div, text] and update", async function() {
            await page.click("#swap27 button.break");
            await waitForSuccessfulUpdate(page, 1);
            await assertChildrenCount("#swap27", 2);
          });
        });
        describe.only("Performance and Compartibility", function() {
          this.timeout(50 * 1000);
          if (version === "Patched-without-extension") {
            it("should not do extra operation when no extension exists", async function() {
              assert.deepEqual(warnings, []);
            });
          } else if (version === "Patched") {
            it("should be correctly tested", async function() {
              assert(warnings.length > 0);
            });
            it("should not redraw too much", async function() {
              const len1 = warnings.length;
              const ids = await page.$$eval(
                ".wrapper",
                items =>
                  items.map(i => i.id).filter(id => !id.startsWith("boundary"))
                // .filter(id => !id.startsWith("swap")) // TODO
              );
              console.log("start breaking");
              for (let id of ids) {
                await page.click(`#${id} button.break`);
              }
              await page.click(`#disable-extension`);
              await page.waitFor(400);
              console.log("end breaking");
              console.log("disabled extension");
              const len2 = warnings.length;
              console.log("start updating");
              for (let id of ids) {
                // console.log(id);
                await page.click(`#${id} button.break`);
              }
              console.log("end updating");
              await page.waitFor(400);
              const len3 = warnings.length;
              assert(len1 < len2);
              assert.equal(len2, len3);

              console.log("start removing .ext");
              for (let id of ids) {
                await page.click(`#${id} button.remove-inserted-node`);
              }
              console.log("end removing .ext");
              const len4 = warnings.length;
              await page.waitFor(400);
              console.log("start updating");
              for (let id of ids) {
                await page.click(`#${id} button.break`);
              }
              console.log("end updating");
              const len5 = warnings.length;
              assert.equal(len4, len5);
            });
          } else {
            it("should be correctly tested", async function() {
              assert.deepEqual(warnings, []);
            });
          }
        });
      });
    }
  });

  after(async function() {
    if (browser) {
      await browser.close();
    }
    if (server) {
      await server.close();
    }
  });
});

describe("No extensions", function() {
  this.slow(50000);
  this.timeout(10000);
  let server;
  let browser;
  let page;
  let error;
  let result;
  before(async function() {
    const app = express();
    app.use(express.static(`${__dirname}/../public`));
    server = app.listen(port);
    browser = await puppeteer.launch({ headless });
    page = await browser.newPage();
    await page.exposeFunction("done", success => {
      result = success;
    });
    page.on("console", async msg => {
      const args = await msg.args();
      const values = await Promise.all(
        args.map(arg => arg.executionContext().evaluate(a => a, arg))
      );
      const strings = values
        .filter(v => {
          if (typeof v === "string") {
            return !v.startsWith("Compiled in DEV mode");
          }
          return true;
        })
        .map(v => chalk.gray(v));
      strings.length && console.log(...strings);
    });
    page.on("pageerror", function(e) {
      error = e;
    });
  });
  beforeEach(function() {
    error = undefined;
    result = undefined;
  });
  for (let src of ["original", "patched"]) {
    const path = src === "original" ? "/" : "/patched.html";
    describe(src, function() {
      for (let main of ["application", "element"]) {
        describe(main, function() {
          it("passes all tests without extension", async function() {
            await page.goto(`http://localhost:${port}${path}?main=${main}`);
            await page.waitForSelector("ul");
            await page.screenshot({
              path: `screenshots/${src}-${main}-before.png`
            });

            for (let i = 0; i < 20; i++) {
              await page.waitFor(50);
              if (result !== undefined) {
                break;
              }
            }
            assert(!error, error);
            assert.equal(result, true);
          });
        });
      }
    });
  }

  after(async function() {
    if (browser) {
      await browser.close();
    }
    if (server) {
      await server.close();
    }
  });
});
