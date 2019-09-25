const puppeteer = require("puppeteer");
const assert = require("assert");
const express = require("express");
const fs = require("fs");
const rimraf = require("rimraf");

const headless = process.env.HEADLESS === "false" ? false : true;

rimraf.sync("screenshots");
fs.mkdirSync("screenshots");

describe("Simple", function() {
  this.slow(1000);
  let browser;
  let page;
  let error;
  before(async function() {
    browser = await puppeteer.launch({ headless });
    page = await browser.newPage();
    page.on("pageerror", function(e) {
      error = e;
    });
    await page.goto(`file://${__dirname}/../public/simple.html`);
    await page.screenshot({ path: "screenshots/simple-before.png" });
  });
  beforeEach(async function() {
    error = undefined;
    await page.reload();
    await page.waitForSelector("ul");
  });
  describe("Insertion", function() {
    it("1", async function() {
      await page.click("#insert1 button");
      await page.waitFor(100);
      assert(!error, error);
    });
    it("2", async function() {
      await page.click("#insert2 button");
      await page.waitFor(100);
      assert(!error, error);
    });
    it("3", async function() {
      await page.click("#insert3 button");
      await page.waitFor(100);
      assert.equal(
        await page.$eval("#insert3 .child", el => el.textContent),
        "after"
      );
      assert(!error, error);
    });
    it("4", async function() {
      await page.click("#insert4 button");
      await page.waitFor(100);
      assert.equal((await page.$$("#insert4 .child.before")).length, 0);
      assert.equal((await page.$$("#insert4 .child.after")).length, 1);
      assert(!error, error);
    });
    it("5", async function() {
      await page.click("#insert5 button");
      await page.waitFor(100);
      assert(!error, error);
    });
  });
  describe("Removal", function() {
    it("1", async function() {
      await page.click("#remove1 button");
      await page.waitFor(100);
      assert(!error, error);
    });
    it("2", async function() {
      await page.click("#remove2 button");
      await page.waitFor(100);
      assert(!error, error);
    });
    it("3", async function() {
      await page.click("#remove3 button");
      await page.waitFor(100);
      assert(!error, error);
    });
    it("4", async function() {
      await page.click("#remove4 button");
      await page.waitFor(100);
      assert(!error, error);
    });
    it("5", async function() {
      await page.click("#remove5 button");
      await page.waitFor(100);
      assert(!error, error);
    });
  });
  after(async function() {
    if (browser) {
      await browser.close();
    }
  });
});

describe("No extensions", function() {
  const port = 3000;
  this.slow(10000);
  this.timeout(10000);
  let browser;
  let page;
  let server;
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
      console.log(...values);
    });
    page.on("pageerror", function(e) {
      error = e;
    });
  });
  beforeEach(function() {
    error = undefined;
    result = undefined;
  });
  for (let main of ["application", "element"]) {
    describe(main, function() {
      it("passes all tests without extension", async function() {
        await page.goto(`http://localhost:${port}?main=${main}`);
        await page.waitForSelector("ul");
        await page.screenshot({ path: `screenshots/${main}-before.png` });

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

  after(async function() {
    if (browser) {
      await browser.close();
    }
    if (server) {
      await server.close();
    }
  });
});
