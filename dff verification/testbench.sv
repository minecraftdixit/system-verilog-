// Code your testbench here
 
class transaction ;
 rand bit  d_in;
  bit  d_out;
  function void display(input string tag);
    $display("[%0s] :din :%0b dout= %0b", tag, d_in, d_out);
    
    
  endfunction
  function transaction copy();
    copy= new();
    copy.d_in = this.d_in;
    copy.d_out = this.d_out;
    
  endfunction
  
endclass

//////////////////////////////////////////generator
class generator;
  mailbox #(transaction) mbx;
  transaction tr;
  int count= 0;
  event sconext;
  event done;
  
  function new(mailbox #(transaction) mbx);
   this.mbx = mbx;
    tr= new();
    endfunction

  task run();
    repeat(count)
      begin 
        assert(tr.randomize) else $error(" [GEN]:RANDOMIZATION FAILED");
        mbx.put(tr.copy);
        tr.display("GEN");
        @(sconext);
        
      end
    ->done;
    
  endtask
 
endclass

////////////////////////////////////////////////driver
class driver;
  transaction tr;
  
  mailbox #(transaction) mbx;
  virtual  dff_if vif;
  function new(mailbox #(transaction) mbx);
   this.mbx = mbx;
     
    endfunction
  
  task reset();
     vif.rst <= 1'b1;
    repeat (5)@(posedge vif.clk);
    vif.rst <= 1'b0;
    repeat(2) @(posedge vif.clk);
    $display("[DRV}:DUT RESET DONE ");
  endtask
  
  task run();
    forever begin 
      mbx.get(tr); 
      @(posedge  vif.clk);
      
    
      vif.d_in <= tr.d_in;
      tr.display("DRV");
      
    end 
  endtask
   
endclass
////////////////////////////////////////////////monitor

class monitor ;
  
  
  transaction tr;
  
  mailbox #(transaction) mbx;
  virtual  dff_if vif;
   function new(mailbox #(transaction) mbx);
   this.mbx = mbx;
     
    endfunction
  task run();
    tr =new();
    forever begin 
      @(posedge vif.clk);
         @(posedge vif.clk);
      tr.d_in = vif.d_in;
      tr.d_out = vif.d_out;
      mbx.put(tr);
      tr.display("MON");
      
    end
  endtask
   
  
  
endclass
/////////////////////////////////////////////////scoreboard
class scoreboard;
   
  transaction tr;
mailbox #(transaction) mbx;
  event sconext;
  
   function new(mailbox #(transaction) mbx);
   this.mbx = mbx;
     
    endfunction

  
  task run();
    forever begin 
      mbx.get(tr);
      tr.display("[SCO]");
      if(tr.d_in == tr.d_out)
        begin
          
          $display("[SCO] :DATA MATCHED!");
          
          
        end
else
  begin 
    $display("[SCO] :DATA NOT MATCHED!");
    ->sconext;
    
  end
    end   
      endtask
  
   

endclass
///////////////////////////////////////////////////////environment
class environment ;
  monitor mon;
  driver drv;
  generator gen;
  scoreboard sco;
  
  event nextgs;
  mailbox #(transaction) mbxgd;
  
  mailbox #(transaction) mbxms;
  virtual dff_if vif;
  
  function new(virtual dff_if vif);
    begin 
      mbxgd = new();
      gen =new(mbxgd);
      drv= new(mbxgd);
      mbxms= new();
      mon= new(mbxms);
      sco = new(mbxms) ;
      this.vif = vif;
      mon.vif= this.vif;
      drv.vif= this.vif;
      
      gen.sconext = nextgs;
      sco.sconext = nextgs;
    end
       endfunction 

      task pre_test();
        drv.reset();

      endtask

      task test();
      fork 
        gen.run();
        drv.run();
        mon.run();
        sco.run();
        
      join_any
      endtask
      
      
      task post_test();
        wait(gen.done.triggered);
        $finish();

      endtask
      
      
      
      task run();
        pre_test();
        test();
        post_test();
      endtask 
      
      
      
      endclass

///////////////////////////////////////////////////////////tb

module tb;
  
  
  dff_if vif();
  
  dff UUT(vif);
  
  initial begin
    vif.clk <=1'b0 ;
    
    
  end
  always #10 vif.clk = ~vif.clk;
  
  environment env;
  
  initial begin 
    
    env = new(vif);	
  env.gen.count = 20;
    env.run();
    
  end
  
  initial begin 
    $dumpfile("test.vcd");
    $dumpvars;
    #1000; $finish();
    
  end
  
endmodule 