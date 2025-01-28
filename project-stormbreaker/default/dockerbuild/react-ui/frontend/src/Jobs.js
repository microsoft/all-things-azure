import * as React from "react";
import axios from "axios";
import { CrudTable, Spinner } from "./components";

export default function Jobs() {
  const [open, setOpen] = React.useState(true);

  const [isLoading, setIsLoading] = React.useState(true);
  const [data, setData] = React.useState([]);

  const host = process.env.REACT_APP_STORMBREAKER_API_HOST || "localhost";
  const port = process.env.REACT_APP_STORMBREAKER_API_PORT || "8000";
  const crud_url = `http://${host}:${port}/api/jobs/`;
  const crud_import_url = `http://${host}:${port}/api/import/`;
  console.log(crud_url);

  const [validationErrors, setValidationErrors] = React.useState({});
  const options_available = ["Guam", "Gustav", "Katrina"];

  /* Column Headers */
  const columns = React.useMemo(
    () => [
      {
        accessorKey: "task",
        header: "Task",
        size: 50,
        enableEditing: false,
      },
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
        accessorKey: "np",
        header: "NP",
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
        header: "Slots",
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

  /* Validators */

  const validateSelect = (value, options) => {
    return options.includes(value);
  };


  const fetchData = async () => {
    setIsLoading(true);
    try {
      /* import new jobs first */
      const import_response = await axios.get(crud_import_url);
      console.log(import_response.data);
      /* then fetch all jobs */
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

  return (
    <React.Fragment>
      {isLoading ? (
        <Spinner />
      ) : data.length === 0 ? (
        <p>No Data Found</p>
      ) : (
        <CrudTable
          data={data}
          fetchData={fetchData}
          setValidationErrors={setValidationErrors}
          columns={columns}
          crud_url={crud_url}
          disableCreate={true}
        />
      )}
    </React.Fragment>
  );
}