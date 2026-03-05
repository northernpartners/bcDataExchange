query 50253 "Dimension Values"
{
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(DimensionValue; "Dimension Value")
        {
            column(dimensionCode; "Dimension Code")
            {
                Caption = 'Dimension Code';
            }
            column(valueCode; Code)
            {
                Caption = 'Value Code';
            }
            column(valueName; Name)
            {
                Caption = 'Value Name';
            }

            filter(dimensionCodeFilter; "Dimension Code")
            {
            }
        }
    }
}
