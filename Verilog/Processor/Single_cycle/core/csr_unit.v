module csr_unit (
    input clk, reset, ret,
    input [7:0] irq_vector,
    output irq_en,
    output [4:0] irq_addr
);
    reg [7:0] irq_service, irq_service_next; 
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            irq_service <= 8'b0;
        end
        else begin
            if (irq_service != 8'b0)
                if (irq_en) 
                    irq_service <= irq_service_next;
                else if(ret)
                    irq_service <= 8'b0;
                else
                    irq_service <= irq_service;
            else
                irq_service <= irq_service_next;
        end
    end
    assign irq_en = irq_vector[7] ? ~irq_service[7] :
                    irq_vector[6] ? ~irq_service[6] :
                    irq_vector[5] ? ~irq_service[5] :
                    irq_vector[4] ? ~irq_service[4] :
                    irq_vector[3] ? ~irq_service[3] :
                    irq_vector[2] ? ~irq_service[2] :
                    irq_vector[1] ? ~irq_service[1] :
                    irq_vector[0] ? ~irq_service[0] : 1'b0;
    always @(*) begin
        casex (irq_vector)
            8'b1???????: begin
                irq_addr = 5'b10000;
                irq_service_next <= 8'b11111111;
            end
            8'b01??????: begin
                irq_addr = 5'b10000;
                irq_service_next <= 8'b01111111;
            end
            8'b001?????: begin
                irq_addr = 5'b10000;
                irq_service_next <= 8'b00111111;
            end
            8'b0001????: begin
                irq_addr = 5'b10000;
                irq_service_next <= 8'b00011111;
            end
            8'b00001???: begin
                irq_addr = 5'b10000;
                irq_service_next <= 8'b00001111;
            end
            8'b000001??: begin
                irq_addr = 5'b10000;
                irq_service_next <= 8'b00000111;
            end
            8'b0000001?: begin 
                irq_addr = 5'b10000;
                irq_service_next <= 8'b00000011;
            end
            8'b00000001: begin 
                irq_addr = 5'b10000;
                irq_service_next <= 8'b00000001;
            end
            8'b00000000: begin
                irq_service_next <= 8'b0;
            end
        endcase
    end
endmodule