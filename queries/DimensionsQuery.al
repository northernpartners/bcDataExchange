query 50252 "Dimensions"
{
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(Dimension; Dimension)
        {
            column(dimensionCode; Code)
            {
                Caption = 'Dimension Code';
            }
            column(dimensionName; Name)
            {
                Caption = 'Dimension Name';
            }
        }
    }
}
