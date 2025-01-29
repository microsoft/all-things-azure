import React, { useState } from "react";  
import {  
  MRT_EditActionButtons,  
  MaterialReactTable,  
  useMaterialReactTable,  
} from "material-react-table";  
import {  
  Box,  
  Button,  
  DialogActions,  
  DialogContent,  
  DialogTitle,  
  IconButton,  
  Tooltip,  
} from "@mui/material";  
  
import EditIcon from "@mui/icons-material/Edit";  
import DeleteIcon from "@mui/icons-material/Delete";  
import axios from "axios";  
  
import { v4 as uuidv4 } from "uuid";  
  
  
const CrudTable = ({  
  data,  
  fetchData,  
  setValidationErrors,  
  columns,  
  crud_url,  
  validateData,  
  disableCreate = false,  
}) => {  
  const [isLoadingDataError, setIsLoadingDataError] = useState(false);  
  
  // CRUD Actions  
  const createData = async (values) => {  
    try {  
      console.log("crud_url: ", crud_url);  
      console.log("values: ", values);  
      const response = await axios.post(crud_url, values);  
      fetchData();  
    } catch (error) {  
      console.log(error);  
    }  
  };  
  
  const updateData = async (values) => {  
    const response = await axios.put(`${crud_url}${values.id}/`, values);  
    fetchData();  
  };  
  
  const deleteData = async (id) => {  
    const response = await axios.delete(`${crud_url}${id}/`);  
    fetchData();  
  };  
  
  //CREATE action  
  const task_id = uuidv4(); // Generate a unique task_id  
  const id = Math.floor(Math.random() * 1000) + 1;    
  
  const handleCreateData = async ({ values, table }) => {  
    console.log(values);  
    const newValidationErrors = validateData(values);  
    if (Object.values(newValidationErrors).some((error) => error)) {  
      setValidationErrors(newValidationErrors);  
      return;  
    }  
    setValidationErrors({});  
  
    // default values;  
    values.id = id;  
    values.task = task_id;  
  
    createData(values);  
    table.setCreatingRow(null); //exit creating mode  
  };  
  
  //UPDATE action  
  const handleSaveData = async ({ values, table }) => {  
    const newValidationErrors = validateData(values);  
    if (Object.values(newValidationErrors).some((error) => error)) {  
      setValidationErrors(newValidationErrors);  
      return;  
    }  
    setValidationErrors({});  
    updateData(values);  
    console.log(values);  
    table.setEditingRow(null); //exit editing mode  
  };  
  
  //DELETE action  
  const openDeleteConfirmModal = (row) => {  
    if (window.confirm("Are you sure you want to delete this job?")) {  
      deleteData(row.original.id);  
      console.log("Deleted job with id: ", row.original.id);  
    }  
  };  
  
  const table = useMaterialReactTable({  
    columns,  
    data: data,  
    enableEditing: true,  
    getRowId: (row) => row.id,  
    muiToolbarAlertBannerProps: isLoadingDataError  
      ? {  
          color: "error",  
          children: "Error loading data",  
        }  
      : undefined,  
    muiTableContainerProps: {  
      sx: {  
        minHeight: "500px",  
      },  
    },  
    onCreatingRowCancel: () => setValidationErrors({}),  
    onCreatingRowSave: handleCreateData,  
    onEditingRowCancel: () => setValidationErrors({}),  
    onEditingRowSave: handleSaveData,  
    renderCreateRowDialogContent: ({ table, row, internalEditComponents }) => (  
      <>  
        <DialogTitle variant="h6">CREATE NEW JOB</DialogTitle>  
        <DialogContent  
          sx={{ display: "flex", flexDirection: "column", gap: "1rem" }}  
        >  
          {internalEditComponents} {/* or render custom edit components here */}  
        </DialogContent>  
        <DialogActions>  
          <MRT_EditActionButtons variant="text" table={table} row={row} />  
        </DialogActions>  
      </>  
    ),  
    renderEditRowDialogContent: ({ table, row, internalEditComponents }) => (  
      <>  
        <DialogTitle variant="h6">EDIT JOB</DialogTitle>  
        <DialogContent  
          sx={{ display: "flex", flexDirection: "column", gap: "1.5rem" }}  
        >  
          {internalEditComponents} {/* or render custom edit components here */}  
        </DialogContent>  
        <DialogActions>  
          <MRT_EditActionButtons variant="text" table={table} row={row} />  
        </DialogActions>  
      </>  
    ),  
    renderRowActions: ({ row, table }) => (  
      <Box sx={{ display: "flex", gap: "1rem" }}>  
        <Tooltip title="Delete">  
          <IconButton color="error" onClick={() => openDeleteConfirmModal(row)}>  
            <DeleteIcon />  
          </IconButton>  
        </Tooltip>  
      </Box>  
    ),      
    renderTopToolbarCustomActions: ({ table }) => (  
      disableCreate ? null : (  
      <Button  
        variant="contained"  
        onClick={() => {  
          table.setCreatingRow(true);  
        }}  
      >  
        Create New Job  
      </Button>  
    )  
    ),  
  
  });  
    
  return <MaterialReactTable table={table} />;  
};  
  
export default CrudTable;  
