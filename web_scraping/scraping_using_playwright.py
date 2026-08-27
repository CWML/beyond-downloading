import time
from datetime import datetime
from pathlib import Path

import pandas as pd
from playwright.async_api import async_playwright


async def scrape_fluview():
    # ==============================================================================
    # Step 1: Identify source + inspect DOM
    # Source: CDC FluView Interactive Portal
    # Targets: Dynamic SPA app requiring headless browser automation to trigger JS modal
    # ==============================================================================
    url = "https://gis.cdc.gov/grasp/fluview/main.html"

    # Set up local paths for auditability
    save_dir = Path.cwd() / "web_scraping" / "downloads"
    save_dir.mkdir(parents=True, exist_ok=True)

    snapshot_path = save_dir / "cdc_fluview_rendered_snapshot.html"
    raw_zip_path = save_dir / "cdc_fluview_data.zip"
    processed_csv_path = save_dir / "cdc_fluview_data_cleaned.csv"

    # ==============================================================================
    # Step 2: Draft selector strategy
    # XPaths targeting interactive buttons and inputs inside the dynamic modal
    # ==============================================================================
    xpath_header_download = "/html/body/div[1]/header/div[4]/button[2]"
    xpath_custom_option = (
        "//*[@id='downloadDataBody']/ul[1]/li[2]/div/ul/li/label"
    )
    xpath_by_week_tab = "//*[@id='customDownloadPanel']/li[2]/div[1]/div/li/a"
    xpath_modal_download = (
        "//*[@id='downloadDataModal']/div/div/div[3]/button[1]"
    )

    # ==============================================================================
    # Step 3: Fetch web page (Dynamic rendering via Playwright)
    # Launch Chromium browser, accept downloads, and load JS-rendered single-page app
    # ==============================================================================
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=False)
        context = await browser.new_context(accept_downloads=True)
        page = await context.new_page()

        print("Step 3: Navigating to CDC FluView application...")
        await page.goto(url, timeout=90000, wait_until="domcontentloaded")
        await page.wait_for_timeout(8000)

        # ==============================================================================
        # Step 4: Extract & clean data
        # Execute automated DOM clicks and listen for browser download stream
        # ==============================================================================
        print("Step 4: Executing modal interactions...")

        # Click Download button in header
        await page.locator(f"xpath={xpath_header_download}").click(
            timeout=60000
        )
        await page.wait_for_timeout(3000)

        # Select Custom Download
        await page.locator(f"xpath={xpath_custom_option}").click(timeout=60000)
        await page.wait_for_timeout(2000)

        # Click By Week tab
        await page.locator(f"xpath={xpath_by_week_tab}").click(timeout=60000)
        await page.wait_for_timeout(2000)

        # Set up download listener BEFORE clicking the trigger button
        async with page.expect_download() as download_info:
            await page.locator(f"xpath={xpath_modal_download}").click(
                timeout=60000
            )

        download = await download_info.value

        # ==============================================================================
        # Step 5: Save HTML snapshot & processed data
        # Capture rendered DOM snapshot alongside raw download payload and CSV dataset
        # ==============================================================================
        # Save raw HTML DOM tree snapshot
        html_content = await page.content()
        snapshot_path.write_text(html_content, encoding="utf-8")

        # Save binary download payload
        await download.save_as(raw_zip_path)

        # Clean browser environment
        await browser.close()

        # Extract/load raw CSV into pandas (CDC packages extra header rows in download)
        df_cleaned = pd.read_csv(raw_zip_path, skiprows=1)
        df_cleaned.columns = (
            df_cleaned.columns.str.strip().str.lower().str.replace(" ", "_")
        )
        df_cleaned.to_csv(processed_csv_path, index=False)

        # ==============================================================================
        # Step 6: Record provenance
        # Document target source, selectors used, execution timestamp, and metrics
        # ==============================================================================
        log_entry = f"""
--- DATA PROVENANCE LOG ---
Target URL      : {url}
Execution Time  : {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
HTML Snapshot   : {snapshot_path.name}
Raw Data File   : {raw_zip_path.name}
Cleaned Data    : {processed_csv_path.name}
Dataset Dims    : {df_cleaned.shape[0]} rows x {df_cleaned.shape[1]} cols
---------------------------
"""
        print(log_entry)
        print(f"✅ Data processed successfully! Preview:\n{df_cleaned.head(3)}")


# Jupyter execution call
await scrape_fluview()