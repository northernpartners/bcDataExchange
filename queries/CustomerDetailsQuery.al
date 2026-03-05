query 50251 "Customer Details"
{
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Customer; Customer)
        {
            // General
            column(customerNo; "No.")
            {
                Caption = 'Customer No.';
            }
            column(customerName; Name)
            {
                Caption = 'Customer Name';
            }
            column(lastDateModified; "Last Date Modified")
            {
                Caption = 'Last Date Modified';
            }
            column(balance; "Balance (LCY)")
            {
                Caption = 'Balance (LCY)';
            }

            // Address & Contact
            column(address; Address)
            {
                Caption = 'Address';
            }
            column(address2; "Address 2")
            {
                Caption = 'Address 2';
            }
            column(countryCode; "Country/Region Code")
            {
                Caption = 'Country/Region Code';
            }
            column(city; City)
            {
                Caption = 'City';
            }
            column(postCode; "Post Code")
            {
                Caption = 'Post Code';
            }
            column(phoneNo; "Phone No.")
            {
                Caption = 'Phone No.';
            }
            column(mobilePhoneNo; "Mobile Phone No.")
            {
                Caption = 'Mobile Phone No.';
            }
            column(email; "E-Mail")
            {
                Caption = 'Email';
            }
            column(languageCode; "Language Code")
            {
                Caption = 'Language Code';
            }

            // Invoicing
            column(vatRegistrationNo; "VAT Registration No.")
            {
                Caption = 'VAT Registration No.';
            }
            column(registrationNo; "Registration Number")
            {
                Caption = 'Registration Number';
            }
            column(currencyCode; "Currency Code")
            {
                Caption = 'Currency Code';
            }
            column(pricesIncludingVAT; "Prices Including VAT")
            {
                Caption = 'Prices Including VAT';
            }

            // Payments
            column(paymentTermsCode; "Payment Terms Code")
            {
                Caption = 'Payment Terms Code';
            }
        }
    }
}
