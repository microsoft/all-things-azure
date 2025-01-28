import axios from "axios";
import * as React from 'react';
import { CrudTable, Spinner } from "./components";

export default function CreateNewJob() {
  const [open, setOpen] = React.useState(true);
  const [isLoading, setIsLoading] = React.useState(true);
  const [data, setData] = React.useState([]);

  const host = process.env.REACT_APP_STORMBREAKER_API_HOST || "localhost";
  const port = process.env.REACT_APP_STORMBREAKER_API_PORT || "8000";
  const crud_url = `http://${host}:${port}/api/jobs/`;

  const [validationErrors, setValidationErrors] = React.useState({});
  const options_available = ["Guam", "Gustav", "Katrina"];

  const sku = [
    "Standard_HB120-16rs_v3",
    "Standard_HB120-32rs_v3",
    "Standard_HB120-64s_v3",
    "Standard_HB120-96rs_v3",
    "Standard_HB120s_v3",
  ];

  const skuCores = {
    "Standard_HB120-16rs_v3": 16,
    "Standard_HB120-32rs_v3": 32,
    "Standard_HB120-64s_v3": 64,
    "Standard_HB120-96rs_v3": 96,
    "Standard_HB120s_v3": 120,
  };

  const nodeNumbers = [1, 2, 3];


  const fetchData = async () => {
    setIsLoading(true);
    try {
      const response = await axios.get(crud_url);
      setData(response.data);
      setIsLoading(false);
      console.log(response.data);
    } catch (error) {
      console.log(error);
      setIsLoading(false);
    }
  };

  React.useEffect(() => {
    fetchData();
  }, []);

  /* Column Headers */
  const columns = React.useMemo(
    () => [
      {
        accessorKey: "customer",
        header: "Customer",
        muiEditTextFieldProps: {
          required: true,
          error: !!validationErrors?.customer,
          helperText: validationErrors?.customer,
          onFocus: () =>
            setValidationErrors({
              ...validationErrors,
              customer: undefined,
            }),
        },
      },
      {
        accessorKey: "simulation",
        header: "Simulation",
        editVariant: "select",
        editSelectOptions: options_available,
        muiEditTextFieldProps: {
          select: true,
          error: !!validationErrors?.simulation,
          helperText: validationErrors?.simulation,
        },
      },
      {
        accessorKey: "sku",
        header: "SKU",
        editVariant: "select",
        editSelectOptions: sku,
        muiEditTextFieldProps: {
          select: true,
          error: !!validationErrors?.sku,
          helperText: validationErrors?.sku,
        },
      },
      {
        accessorKey: "nodeNumber",
        header: "Number of Nodes",
        editVariant: "select",
        editSelectOptions: nodeNumbers,
        muiEditTextFieldProps: {
          select: true,
          error: !!validationErrors?.nodeNumber,
          helperText: validationErrors?.nodeNumber,
        },
      },
      {
        accessorKey: "np",
        header: "Total number of cores",
        muiEditTextFieldProps: {
          required: true,
          error: !!validationErrors?.np,
          helperText: validationErrors?.np,
          onFocus: () =>
            setValidationErrors({
              ...validationErrors,
              np: undefined,
            }),
        },
      },
      {
        accessorKey: "slots",
        header: "Cores per node",
        muiEditTextFieldProps: {
          required: true,
          error: !!validationErrors?.slots,
          helperText: validationErrors?.slots,
          onFocus: () =>
            setValidationErrors({
              ...validationErrors,
              slots: undefined,
            }),
        },
      },
    ],
    [validationErrors]
  );

  // Validators
  const validateLength = (value, field, lowest) => {
    if (value.length === 0) {
      return `${field} cannot be empty`;
    } else if (value.length < lowest) {
      return `A minimum of ${lowest} Characters is required`;
    } else {
      return "";
    }
  };

  const validateMinNumber = (value, minimum) => {
    return value > minimum;
  };

  const validateSelect = (value, options) => {
    if (!options.includes(value)) {
      return "Option Unavailable";
    } else {
      return "";
    }
  };

  const validateNP = (np, nodeNumber, slots) => {
    const maximumValue = nodeNumber * slots;
    if (np > maximumValue) {
      return `Invalid number of cores. Maximum value allowed: ${maximumValue}`;
    } else {
      return "";
    }
  };

  const validateSlots = (slots, sku) => {
    const maximumValue = skuCores[sku];
    if (slots > maximumValue) {
      return `Invalid number of cores. Maximum value allowed: ${maximumValue}`;
    } else {
      return "";
    }
  };

  function validateData(data) {
    return {
      name: validateLength(data.customer, "Customer", 1),
      simulation: validateSelect(data.simulation, options_available),
      sku: validateSelect(data.sku, sku),
      np: validateNP(data.np, data.nodeNumber, data.slots),
      slots: validateSlots(data.slots, data.sku),
    };
  }
  return (
    <React.Fragment>
      <CrudTable
        data={data}
        fetchData={fetchData}
        setValidationErrors={setValidationErrors}
        columns={columns}
        crud_url={crud_url}
        validateData={validateData}
      />
    </React.Fragment>
  );
}