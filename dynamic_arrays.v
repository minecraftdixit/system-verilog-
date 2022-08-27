 // create dynamic  arrays and use randomizationn alongwith  constraints : 

class myclass ;
 rand  int arr1[];
  rand int arr2[];
   rand  int arr3[];
  rand int arr4[];
  constraint rand_{
    arr1.size==20;
    arr2.size==30;
    arr3.size==20;
    arr4.size==30;
    
  } 
  constraint ran1_{
    foreach(arr1[i]) arr1[i] inside {[30:40]};
    foreach(arr2[i]) arr2[i] inside {[20:40]};
    //arr2.sum>100;
    arr3.sum<300;
    }
  function  void display();
    $display("arr1_size=%d , arr2_size =%d ,arr3_size=%d , arr4_size =%d ",arr1.size, arr2.size, arr3.size, arr4.size );
    $display("array 1 element sum :%p", arr1);
    $display("array 2 element sum :%p", arr2);
    $display("array 3 element sum:%0f", arr3.sum);
    $display("array 4 element sum :%0f", arr4.sum);
  endfunction
endclass

module ex ;
  myclass ac;
  initial 
    begin 
  ac = new();
  repeat(10);
    begin 
      
      ac.randomize(); 
      ac.display();
 
    end
    end
endmodule
