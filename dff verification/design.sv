// Code your design here
module dff(dff_if inf);
  always@(posedge inf.clk)
    begin
      if(inf.rst)
        begin 
          inf.d_out<=0;
        end
      else
        inf.d_out <= inf.d_in;
    end
  
  
  
endmodule


interface dff_if;
  logic clk;
   logic rst;
  
   logic d_in ;
  
   logic d_out ;
  
   
  
endinterface 
  
  