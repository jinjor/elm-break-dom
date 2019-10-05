const puppeteer = require("puppeteer");
const assert = require("assert");
const express = require("express");
const fs = require("fs");
const rimraf = require("rimraf");
const chalk = require("chalk");

const port = 3000;
const headless = process.env.HEADLESS === "false" ? false : true;

rimraf.sync("screenshots");
fs.mkdirSync("screenshots");

async function assertCount(page, selector, n) {
  assert.equal((await page.$$(selector)).length, n);
}

describe("Simple", function() {
  this.slow(2000);
  this.timeout(3000);
  let server;
  let browser;
  let page;
  let error;
  before(async function() {
    const app = express();
    app.use(express.static(`${__dirname}/../public`));
    server = app.listen(port);
    browser = await puppeteer.launch({ headless });
    page = await browser.newPage();
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
  beforeEach(async function() {
    error = undefined;
  });
  for (let version of ["Original", "Patched"]) {
    describe(version, function() {
      const html =
        version === "Original" ? "simple.html" : "simple-patched.html";
      for (let main of ["application", "element"]) {
        describe(main, function() {
          before(async function() {
            await page.goto(`http://localhost:${port}/${html}?main=${main}`);
            await page.screenshot({
              path: `screenshots/simple-${main}-before.png`
            });
          });
          beforeEach(async function() {
            await page.reload();
            try {
              await page.waitForSelector("ul", { timeout: 100 });
            } catch (e) {
              await page.$eval("body", body => console.log(body.innerHTML));
              throw e;
            }
          });
          describe("Insert into <body>", function() {
            it("at (top = 0, bottom = 0)", async function() {
              await page.click("#insert-into-body1 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "body > .top", 0);
              await assertCount(page, "body > .bottom", 0);
            });
            it("at (top = 0, bottom = 1)", async function() {
              await page.click("#insert-into-body2 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "body > .top", 0);
              await assertCount(page, "body > .bottom", 1);
            });
            it("at (top = 0, bottom = 2)", async function() {
              await page.click("#insert-into-body3 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "body > .top", 0);
              await assertCount(page, "body > .bottom", 2);
            });
            it("at (top = 1, bottom = 0)", async function() {
              await page.click("#insert-into-body4 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "body > .top", 1);
              await assertCount(page, "body > .bottom", 0);
            });
            it("at (top = 1, bottom = 1)", async function() {
              await page.click("#insert-into-body5 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "body > .top", 1);
              await assertCount(page, "body > .bottom", 1);
            });
            it("at (top = 1, bottom = 2)", async function() {
              await page.click("#insert-into-body6 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "body > .top", 1);
              await assertCount(page, "body > .bottom", 2);
            });
            it("at (top = 2, bottom = 0)", async function() {
              await page.click("#insert-into-body7 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "body > .top", 2);
              await assertCount(page, "body > .bottom", 0);
            });
            it("at (top = 2, bottom = 1)", async function() {
              await page.click("#insert-into-body8 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "body > .top", 2);
              await assertCount(page, "body > .bottom", 1);
            });
          });
          describe("Insert before target element", function() {
            it("...and update target's grand child", async function() {
              await page.click("#insert1 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target's child", async function() {
              await page.click("#insert2 button");
              await page.waitFor(100);
              assert.equal(
                await page.$eval("#insert2 .target", el => el.textContent),
                "after"
              );
              assert(!error, error);
            });
            it("...and update target's next element", async function() {
              await page.click("#insert3 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target's class", async function() {
              await page.click("#insert4 button");
              await page.waitFor(100);
              assert.equal(
                (await page.$$("#insert4 .target.before")).length,
                0
              );
              assert.equal((await page.$$("#insert4 .target.after")).length, 1);
              assert(!error, error);
            });
            it("...and update target's previous element", async function() {
              await page.click("#insert5 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and replace previous element (text -> div)", async function() {
              await page.click("#insert6 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#insert6 .e1")).length, 1);
            });
            it("...and replace previous element (div -> text)", async function() {
              await page.click("#insert7 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#insert7 .e1")).length, 0);
            });
            it("...and remove target", async function() {
              await page.click("#insert8 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and insert text before target", async function() {
              await page.click("#insert9 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and insert <div> before target", async function() {
              await page.click("#insert10 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#insert10 .e1")).length, 1);
            });
            it("...and insert <a> before target", async function() {
              await page.click("#insert11 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#insert11 .e1")).length, 1);
            });
            it("...and replace target with <a>", async function() {
              await page.click("#insert12 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#insert12 .e1")).length, 1);
            });
            it("...and remove target's previous <div>", async function() {
              await page.click("#insert13 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#insert13 .e1")).length, 0);
            });
            it("...and remove target's previous <a>", async function() {
              await page.click("#insert14 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#insert14 .e1")).length, 0);
            });
            it("...and remove target's previous text", async function() {
              await page.click("#insert15 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and insert text after target", async function() {
              await page.click("#insert16 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and insert <div> after target", async function() {
              await page.click("#insert17 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#insert17 .e1")).length, 1);
            });
            it("...and insert <a> after target", async function() {
              await page.click("#insert18 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#insert18 .e1")).length, 1);
            });
            it("...and remove <div> after target", async function() {
              await page.click("#insert19 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#insert19 .e1")).length, 0);
            });
            it("...and remove <a> after target", async function() {
              await page.click("#insert20 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#insert20 .e1")).length, 0);
            });
            it("...and remove text after target", async function() {
              await page.click("#insert21 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("22-28", async function() {
              for (let i = 22; i <= 28; i++) {
                await page.click(`#insert${i} button`);
                await page.waitFor(50);
                assert(!error, error);
              }
            });
          });
          describe("Append to target element", function() {
            it("...and update target's attribute", async function() {
              await page.click("#append1 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "#append1 .ext", 1);
              await assertCount(page, "#append1 .target.before", 0);
              await assertCount(page, "#append1 .target.after", 1);
            });
            it("...and update target's child", async function() {
              await page.click("#append2 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "#append2 .ext", 1);
            });
            it("...and insert text into target", async function() {
              await page.click("#append3 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "#append3 .ext", 1);
            });
            it("...and insert <div> into target", async function() {
              await page.click("#append4 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "#append4 .ext", 1);
              await assertCount(page, "#append4 .e1", 1);
            });
            it("...and insert <a> into target", async function() {
              await page.click("#append5 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "#append5 .ext", 1);
              await assertCount(page, "#append5 .e1", 1);
            });
            it("...and remove text from target", async function() {
              await page.click("#append6 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "#append6 .ext", 1);
            });
            it("...and remove <div> from target", async function() {
              await page.click("#append7 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "#append7 .ext", 1);
              await assertCount(page, "#append7 .e1", 0);
            });
            it("...and remove <a> from target", async function() {
              await page.click("#append8 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "#append8 .ext", 1);
              await assertCount(page, "#append8 .e1", 0);
            });
            it("...and remove 2 texts from target", async function() {
              await page.click("#append9 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "#append9 .ext", 1);
            });
            it("...and remove 2 <div>s from target", async function() {
              await page.click("#append10 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "#append10 .ext", 1);
              await assertCount(page, "#append10 .e1", 0);
              await assertCount(page, "#append10 .e2", 0);
            });
            it("...and replace target with text", async function() {
              await page.click("#append11 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "#append11 .target", 0);
              await assertCount(page, "#append11 .ext", 0);
            });
            it("...and remove target", async function() {
              await page.click("#append12 button");
              await page.waitFor(100);
              assert(!error, error);
              await assertCount(page, "#append12 .target", 0);
              await assertCount(page, "#append12 .ext", 0);
            });
          });
          describe("Remove target element", function() {
            it("...and update target's grand child", async function() {
              await page.click("#remove1 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target's child", async function() {
              await page.click("#remove2 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target's next element", async function() {
              await page.click("#remove3 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target's class", async function() {
              await page.click("#remove4 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target's previous element", async function() {
              await page.click("#remove5 button");
              await page.waitFor(100);
              assert(!error, error);
            });
          });
          describe("Wrap target element", function() {
            it("...and update target's child", async function() {
              await page.click("#wrap1 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target's class", async function() {
              await page.click("#wrap2 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target's next element", async function() {
              await page.click("#wrap3 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target's previous element", async function() {
              await page.click("#wrap4 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target's child (same tag)", async function() {
              await page.click("#wrap5 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target's class (same tag)", async function() {
              await page.click("#wrap6 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#wrap6 .target.before")).length, 0);
              assert.equal((await page.$$("#wrap6 .target.after")).length, 1);
            });
            it("...and update target's next element (same tag)", async function() {
              await page.click("#wrap7 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target's previous element (same tag)", async function() {
              await page.click("#wrap8 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and replace target with text", async function() {
              await page.click("#wrap9 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#wrap9 .target")).length, 0);
            });
            it("...and replace target with <a>", async function() {
              await page.click("#wrap10 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#wrap10 .target")).length, 0);
              assert.equal((await page.$$("#wrap10 .e1")).length, 1);
            });
            it("...and replace target with <font> (same tag)", async function() {
              await page.click("#wrap11 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#wrap11 .target")).length, 0);
              assert.equal((await page.$$("#wrap11 .e1")).length, 1);
            });
            it("...and remove target", async function() {
              await page.click("#wrap12 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#wrap12 .target")).length, 0);
            });
            it("...and replace with 2 text nodes", async function() {
              await page.click("#wrap13 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#wrap13 .target")).length, 0);
            });
            it("...and replace with 2 <a> nodes", async function() {
              await page.click("#wrap14 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#wrap14 .target")).length, 0);
              assert.equal((await page.$$("#wrap14 .e1")).length, 1);
              assert.equal((await page.$$("#wrap14 .e2")).length, 1);
            });
            it("...and insert <a> after target", async function() {
              await page.click("#wrap15 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#wrap15 .target")).length, 1);
              assert.equal((await page.$$("#wrap15 .e1")).length, 0);
              assert.equal((await page.$$("#wrap15 .e2")).length, 1);
              assert.equal((await page.$$("#wrap15 .e3")).length, 1);
            });
            it("...and insert <a> before target", async function() {
              await page.click("#wrap16 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#wrap16 .target")).length, 1);
              assert.equal((await page.$$("#wrap16 .e1")).length, 0);
              assert.equal((await page.$$("#wrap16 .e2")).length, 1);
              assert.equal((await page.$$("#wrap16 .e3")).length, 1);
            });
            it("...and insert <font> before target", async function() {
              await page.click("#wrap17 button");
              await page.waitFor(100);
              assert(!error, error);
              assert.equal((await page.$$("#wrap17 .target")).length, 1);
              assert.equal((await page.$$("#wrap17 .e1")).length, 0);
              assert.equal((await page.$$("#wrap17 .e2")).length, 1);
              assert.equal((await page.$$("#wrap17 .e3")).length, 1);
            });
          });
          describe("Update target attribute", function() {
            it("...and update target and it's child 1", async function() {
              await page.click("#update-attribute1 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target and it's child 2", async function() {
              await page.click("#update-attribute2 button");
              await page.waitFor(100);
              assert(!error, error);
            });
            it("...and update target's attribute", async function() {
              await page.click("#update-attribute3 button");
              await page.waitFor(100);
              assert(!error, error);
            });
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
              await page.waitFor(100);
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
