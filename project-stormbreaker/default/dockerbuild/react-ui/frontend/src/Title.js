import Typography from '@mui/material/Typography';

const Title = ({ children }) => {
  return (
    <Typography variant="h5" component="h2" gutterBottom>
      {children}
    </Typography>
  );
};

export default Title;  
