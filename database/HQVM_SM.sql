create or replace package hqvm_sm
is

procedure handle_readings
  ( p_json in blob
  );

procedure bepaal_dayreadings;

end;
