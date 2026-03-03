query 50250 "Customers"
{
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Customer; Customer)
        {
            column(customerNo; "No.")
            {
                Caption = 'Customer No.';
            }
            column(customerName; Name)
            {
                Caption = 'Customer Name';
            }
            column(vatRegistrationNumber; "VAT Registration No.")
            {
                Caption = 'VAT Registration Number';
            }
            column(registrationNumber; "Registration Number")
            {
                Caption = 'Registration Number';
            }

            filter(noFilter; "No.")
            {
            }
            filter(nameFilter; Name)
            {
            }
            filter(vatFilter; "VAT Registration No.")
            {
            }
            filter(registrationFilter; "Registration Number")
            {
            }
        }
    }
}
