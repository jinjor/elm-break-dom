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

describe("Simple", function() {
  this.slow(5000);
  this.timeout(1000);
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
        .filter(
          v => typeof v !== "string" || !v.startsWith("Compiled in DEV mode")
        )
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
            await page.waitForSelector("ul");
          });
          describe("Insert into <body>", function() {
            it("at the top", async function() {
              await page.click("#insert-into-body1 button");
              await page.waitFor(100);
              await page.screenshot({
                path: `screenshots/debug-body-top-${main}.png`
              });
              assert(!error, error);
            });
            it("at the bottom", async function() {
              await page.click("#insert-into-body2 button");
              await page.waitFor(100);
              assert(!error, error);
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
              assert.equal((await page.$$("#wrap6 .target.before")).length, 0);
              assert.equal((await page.$$("#wrap6 .target.after")).length, 1);
              assert(!error, error);
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
        .filter(v => !v.startsWith("Compiled in DEV mode"))
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
