const puppeteer = require("puppeteer");
const assert = require("assert");

describe("insertion", function() {
  let browser;
  let page;
  let error;
  before(async function() {
    browser = await puppeteer.launch();
  });
  beforeEach(async function() {
    error = undefined;
    page = await browser.newPage();
    page.on("pageerror", function(e) {
      error = e;
    });
    await page.goto(`file://${__dirname}/../public/insertion.html`);
  });
  it("does not emit error", async function() {
    await page.waitFor(100);
    assert(!error, error);
  });
  after(async function() {
    if (browser) {
      await browser.close();
    }
  });
});

describe("removal", function() {
  let browser;
  let page;
  let error;
  before(async function() {
    browser = await puppeteer.launch();
  });
  beforeEach(async function() {
    error = undefined;
    page = await browser.newPage();
    page.on("pageerror", function(e) {
      error = e;
    });
    await page.goto(`file://${__dirname}/../public/removal.html`);
  });
  it("does not emit error", async function() {
    await page.waitFor(100);
    assert(!error, error);
  });
  after(async function() {
    if (browser) {
      await browser.close();
    }
  });
});
