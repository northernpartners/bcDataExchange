codeunit 50152 "Sales Invoice Handler"
{
    Permissions =
        tabledata "Sales Header" = rimd,
        tabledata "Sales Line" = rimd;

    trigger OnRun()
    begin
    end;

    /// <summary>
    /// POST endpoint for processing invoice operations.
    /// Accepts JSON with an "action" field to determine the operation.
    /// Supported actions: getDraftDetails, getPostedDetails, createDraft.
    /// </summary>
    [ServiceEnabled]
    procedure ProcessInvoice(requestBody: Text): Text
    var
        InObj: JsonObject;
    begin
        if not InObj.ReadFrom(requestBody) then
            exit(CreateErrorResponse('Invalid JSON in requestBody.'));

        exit(ProcessInvoiceOperation(InObj));
    end;

    /// <summary>
    /// Processes invoice operations based on the requested action.
    /// </summary>
    local procedure ProcessInvoiceOperation(InObj: JsonObject): Text
    var
        ActionToken: JsonToken;
        Action: Text;
    begin
        if not InObj.Get('action', ActionToken) or not ActionToken.IsValue() then
            exit(CreateErrorResponse('Missing or invalid "action" field.'));

        Action := ActionToken.AsValue().AsText();

        case Action of
            'getDraftDetails':
                exit(GetDraftInvoiceDetails(InObj));
            'getPostedDetails':
                exit(GetPostedInvoiceDetails(InObj));
            'createDraft':
                exit(CreateDraftInvoice(InObj));
            else
                exit(CreateErrorResponse('Unknown action: ' + Action));
        end;
    end;

    /// <summary>
    /// Gets full details of a draft invoice including all line items and optional dimensions.
    /// </summary>
    local procedure GetDraftInvoiceDetails(InObj: JsonObject): Text
    var
        Helpers: Codeunit "Sales Invoice Helpers";
        InvoiceIdToken: JsonToken;
        DimensionsToken: JsonToken;
        InvoiceId: Code[20];
        SalesHeader: Record "Sales Header";
        DimensionArray: JsonArray;
    begin
        if not InObj.Get('invoiceId', InvoiceIdToken) or not InvoiceIdToken.IsValue() then
            exit(CreateErrorResponse('Missing or invalid "invoiceId" field.'));

        InvoiceId := CopyStr(InvoiceIdToken.AsValue().AsText(), 1, MaxStrLen(InvoiceId));

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SetRange("No.", InvoiceId);
        SalesHeader.SetRange(Status, SalesHeader.Status::Open);

        if not SalesHeader.FindFirst() then
            exit(CreateErrorResponse('Invoice not found', 'The requested draft invoice does not exist.'));

        // Extract optional dimensions array
        if InObj.Get('dimensions', DimensionsToken) and DimensionsToken.IsArray() then
            DimensionArray := DimensionsToken.AsArray()
        else
            Clear(DimensionArray);

        exit(Helpers.CreateInvoiceDetailObject(SalesHeader, DimensionArray));
    end;

    /// <summary>
    /// Gets full details of a posted invoice including all line items and optional dimensions.
    /// </summary>
    local procedure GetPostedInvoiceDetails(InObj: JsonObject): Text
    var
        Helpers: Codeunit "Sales Invoice Helpers";
        InvoiceIdToken: JsonToken;
        DimensionsToken: JsonToken;
        InvoiceId: Code[20];
        SalesInvoiceHeader: Record "Sales Invoice Header";
        DimensionArray: JsonArray;
    begin
        if not InObj.Get('invoiceId', InvoiceIdToken) or not InvoiceIdToken.IsValue() then
            exit(CreateErrorResponse('Missing or invalid "invoiceId" field.'));

        InvoiceId := CopyStr(InvoiceIdToken.AsValue().AsText(), 1, MaxStrLen(InvoiceId));

        SalesInvoiceHeader.SetRange("No.", InvoiceId);

        if not SalesInvoiceHeader.FindFirst() then
            exit(CreateErrorResponse('Invoice not found', 'The requested posted invoice does not exist.'));

        // Extract optional dimensions array
        if InObj.Get('dimensions', DimensionsToken) and DimensionsToken.IsArray() then
            DimensionArray := DimensionsToken.AsArray()
        else
            Clear(DimensionArray);

        exit(Helpers.CreatePostedInvoiceDetailObject(SalesInvoiceHeader, DimensionArray));
    end;

    /// <summary>
    /// Creates a new draft invoice with the provided parameters.
    /// Validates all required fields and returns the new invoice number or error.
    /// </summary>
    local procedure CreateDraftInvoice(InObj: JsonObject): Text
    var
        Helpers: Codeunit "Sales Invoice Helpers";
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        CustomerIdToken: JsonToken;
        DocumentDateToken: JsonToken;
        DueDateToken: JsonToken;
        CurrencyCodeToken: JsonToken;
        PaymentTermsCodeToken: JsonToken;
        CustomerId: Code[20];
        DocumentDate: Date;
        DueDate: Date;
        CurrencyCode: Code[10];
        PaymentTermsCode: Code[10];
        Result: JsonObject;
        OutTxt: Text;
    begin
        // Validate and extract customerId
        if not InObj.Get('customerId', CustomerIdToken) or not CustomerIdToken.IsValue() then
            exit(CreateErrorResponse('Missing or invalid "customerId" field.'));

        CustomerId := CopyStr(CustomerIdToken.AsValue().AsText(), 1, MaxStrLen(CustomerId));

        if not Customer.Get(CustomerId) then
            exit(CreateErrorResponse('Customer not found', 'The customer with ID "' + CustomerId + '" does not exist.'));

        // Validate and extract documentDate
        if not InObj.Get('documentDate', DocumentDateToken) or not DocumentDateToken.IsValue() then
            exit(CreateErrorResponse('Missing or invalid "documentDate" field.'));

        if not Helpers.ParseDateISO(DocumentDateToken.AsValue().AsText(), DocumentDate) then
            exit(CreateErrorResponse('Invalid date format', 'documentDate must be in YYYY-MM-DD format.'));

        // Extract dueDate (optional - will be set by paymentTermsCode if omitted)
        Clear(DueDate);
        if InObj.Get('dueDate', DueDateToken) and DueDateToken.IsValue() then begin
            if not Helpers.ParseDateISO(DueDateToken.AsValue().AsText(), DueDate) then
                exit(CreateErrorResponse('Invalid date format', 'dueDate must be in YYYY-MM-DD format.'));
        end;

        // Validate and extract currencyCode
        if not InObj.Get('currencyCode', CurrencyCodeToken) or not CurrencyCodeToken.IsValue() then
            exit(CreateErrorResponse('Missing or invalid "currencyCode" field.'));

        CurrencyCode := CopyStr(CurrencyCodeToken.AsValue().AsText(), 1, MaxStrLen(CurrencyCode));

        // Extract paymentTermsCode (optional)
        if InObj.Get('paymentTermsCode', PaymentTermsCodeToken) and PaymentTermsCodeToken.IsValue() then
            PaymentTermsCode := CopyStr(PaymentTermsCodeToken.AsValue().AsText(), 1, MaxStrLen(PaymentTermsCode))
        else
            Clear(PaymentTermsCode);

        // Create the invoice
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);

        // Set customer and dates
        SalesHeader.Validate("Sell-to Customer No.", CustomerId);
        SalesHeader.Validate("Document Date", DocumentDate);
        if DueDate <> 0D then
            SalesHeader.Validate("Due Date", DueDate);
        SalesHeader.Validate("Currency Code", CurrencyCode);
        SalesHeader.Validate("Payment Terms Code", PaymentTermsCode);
        SalesHeader.Modify(true);

        // Build and return response
        Result.Add('invoiceNumber', SalesHeader."No.");
        Result.Add('customerId', SalesHeader."Sell-to Customer No.");
        Result.Add('dueDate', Helpers.FormatDateISO(SalesHeader."Due Date"));
        Result.Add('documentDate', Helpers.FormatDateISO(SalesHeader."Document Date"));
        Result.Add('currencyCode', SalesHeader."Currency Code");
        Result.Add('paymentTermsCode', SalesHeader."Payment Terms Code");
        Result.Add('status', 'Open');
        Result.Add('amount', 0.00);
        Result.Add('amountExcludingVat', 0.00);
        Result.Add('vat', 0.00);

        Result.WriteTo(OutTxt);
        exit(OutTxt);
    end;

    /// <summary>
    /// Creates a standardized error response JSON object.
    /// </summary>
    local procedure CreateErrorResponse(ErrorCode: Text; ErrorMessage: Text): Text
    var
        Result: JsonObject;
        OutTxt: Text;
    begin
        Result.Add('error', true);
        Result.Add('code', ErrorCode);
        Result.Add('message', ErrorMessage);
        Result.WriteTo(OutTxt);
        exit(OutTxt);
    end;

    /// <summary>
    /// Creates a standardized error response with just a message.
    /// </summary>
    local procedure CreateErrorResponse(ErrorMsg: Text): Text
    var
        Result: JsonObject;
        OutTxt: Text;
    begin
        Result.Add('success', false);
        Result.Add('error', ErrorMsg);
        Result.WriteTo(OutTxt);
        exit(OutTxt);
    end;
}
