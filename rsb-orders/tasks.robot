*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library    RPA.Browser.Selenium    auto_close=${false}
Library    RPA.HTTP
Library    RPA.Tables
Library    RPA.PDF
Library    RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open browser
    Download CSV
    ${orders}=    Get orders
    
    FOR    ${order}    IN    @{orders}
        Close the annoying modal
        Fill in order form    ${order}
        Display preview
        ${screenshot}=    Take a screenshot of a robot    ${order}[Order number]
        Wait Until Keyword Succeeds    5x   0.5 sec   Submit order
        ${pdf}=    Store the receipt as a PDF file    ${order}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Order another
    END
    
    
    Zip output Files
    [Teardown]    Close Browser

*** Keywords ***
Open browser
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    ${orders}=    Read table from CSV    orders.csv    header=true
    RETURN    ${orders}

Download CSV
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=true

Fill in order form
    [Arguments]    ${order}
    Select From List By Index    id:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    class:form-control    ${order}[Legs]
    Input Text    address    ${order}[Address]
    

Close the annoying modal
    Click Button When Visible    css:#root > div > div.modal > div > div > div > div > div > button.btn.btn-dark

Display preview
    Click Button    preview
    Wait Until Element Is Visible    id:robot-preview-image

Submit order
    Click Button    order
    Wait Until Page Contains Element    id:receipt    timeout=2 sec

Order another
    Click Button    order-another

Take a screenshot of a robot
    [Arguments]    ${fileName}
    ${filePath}=    Set Variable    ${OUTPUT_DIR}${/}Screenshots${/}${fileName}.png
    Screenshot    id:robot-preview-image    ${filePath}
    RETURN    ${filePath}

Store the receipt as a PDF file
    [Arguments]    ${fileName}
    Wait Until Element Is Visible    id:receipt
    ${orderReceipt}=    Get Element Attribute    id:receipt    outerHTML
    ${filePath}=    Set Variable   ${OUTPUT_DIR}${/}Receipts${/}${fileName}.pdf
    Html To Pdf    ${orderReceipt}    ${filePath}
    RETURN    ${filePath}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    @{screenshotList}=    Create List    ${screenshot}
    Open Pdf    ${pdf}
    Add Files To Pdf    ${screenshotList}    ${pdf}    append=true
    Close Pdf    ${pdf}

Zip output Files
    Archive Folder With Zip    ${OUTPUT_DIR}${/}Receipts    receipts.zip
    
