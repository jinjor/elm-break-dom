const puppeteer = require("puppeteer");
const assert = require("assert");
const headless = process.env.HEADLESS === "false" ? false : true;

describe("Basics", function() {
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
    await page.goto(`file://${__dirname}/../public/index.html`);
    await page.screenshot({ path: "screenshots/basics-init.png" });
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
