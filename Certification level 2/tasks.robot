*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.Excel.Files
Library             RPA.HTTP
Library             RPA.Tables
Library             Dialogs
Library             XML
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Windows


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Open the intranet website
    Download the CSV file
    Table Keywords
    Create ZIP package from PDF files
    Close Application


*** Keywords ***
Open the intranet website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download the CSV file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True

Table Keywords
    ${Tables}=    Read table from CSV    orders.csv
    FOR    ${row}    IN    @{Tables}
        Fill the form using the data from the CSV file    ${row}
        Collect the screenshot    ${row}
        Save the PDF    ${row}
        Attach robot screenshot to the receipt PDF file    ${row}
        Order another robot
    END

Fill the form using the data from the CSV file
    [Arguments]    ${row}
    Click Button    Yep
    Select From List By Index    id:head    ${row}[Head]
    Wait And Click Button    id:id-body-${row}[Body]
    Input Text    class:form-control    ${row}[Legs]
    Input Text    id:address    ${row}[Address]
    Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview-image
    Wait Until Keyword Succeeds    3x    1s    Order

Order
    Click Button    id:order
    Sleep    7s
    Wait Until Page Contains Element    id:receipt

Order another robot
    Wait And Click Button    id:order-another

Save the PDF
    [Arguments]    ${row}
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}${row}[Order number].pdf    overwrite=True
    Html To Pdf    ${receipt_html}    ${OUTPUT_DIR}${/}Robot_Receipts${/}${row}[Order number].pdf    overwrite=True

Collect the screenshot
    [Arguments]    ${row}
    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}${row}[Order number].png

Attach robot screenshot to the receipt PDF file
    [Arguments]    ${row}
    Open Pdf    ${OUTPUT_DIR}${/}${row}[Order number].pdf
    Add Watermark Image To Pdf
    ...    ${OUTPUT_DIR}${/}${row}[Order number].png
    ...    ${OUTPUT_DIR}${/}${row}[Order number].pdf
    ${pdfFiles}=    Create List    ${OUTPUT_DIR}${/}${row}[Order number].pdf
    Add Files To Pdf    ${pdfFiles}    ${OUTPUT_DIR}${/}Robotreceipts.pdf    append=True

Create ZIP package from PDF files
    ${ReceiptsZip}=    Set Variable    ${OUTPUT_DIR}${/}Robot_Receipts.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}Robot_Receipts    ${ReceiptsZip}

 Close Application
    Close Browser
