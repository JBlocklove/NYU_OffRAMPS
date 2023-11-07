`timescale 1ns / 1ps
module OffRAMPS_top(
    // Board Specific IO
    input sysclk,   // System clock
    output led0_g,  // LED 0 Green
    output led0_r,  // LED 0 Red
    input btn0,    // Button[0]

    // Thermocouple inputs
    input i_THERM0_n_0,  // Thermocouple 0 Negative Single-ended input [0]
    input i_THERM0_p_0,  // Thermocouple 0 Positive Single-ended input [0]
    input i_THERM1_n_1,  // Thermocouple 1 Negative Single-ended input [1]
    input i_THERM1_p_1,  // Thermocouple 1 Positive Single-ended input [1]

    // Printer Specific IO
    input i_D10,         // D10 input
    input i_D8,          // D8 input
    input i_D9,          // D9 input
    input i_E0_DIR,      // Extruder 0 Direction input
    input i_E0_EN,       // Extruder 0 Enable input
    input i_E0_STEP,     // Extruder 0 Step input
    input i_THERM0_SCL,  // Thermocouple 0 SCL input
    input i_THERM0_SDA,  // Thermocouple 0 SDA input
    input i_THERM1_SCL,  // Thermocouple 1 SCL input
    input i_THERM1_SDA,  // Thermocouple 1 SDA input
    input i_UART_RX,     // UART RX input 
    input i_UART_TX,     // UART TX input
    input i_X_DIR,       // X Direction input
    input i_X_EN,        // X Enable input
    input i_X_MAX,       // X Max input
    input i_X_MIN,       // X Min input
    input i_X_STEP,      // X Step input
    input i_Y_DIR,       // Y Direction input
    input i_Y_EN,        // Y Enable input
    input i_Y_MAX,       // Y Max input
    input i_Y_MIN,       // Y Min input
    input i_Y_STEP,      // Y Step input
    input i_Z_DIR,       // Z Direction input
    input i_Z_EN,        // Z Enable input
    input i_Z_MAX,       // Z Max input
    input i_Z_MIN,       // Z Min input
    input i_Z_STEP,      // Z Step input
    
    output o_D10,        // D10 output
    output o_D9,         // D9 output
    output o_E0_DIR,     // Extruder 0 Direction output
    output o_E0_EN,      // Extruder 0 Enable output
    output o_E0_STEP,    // Extruder 0 Step output
    output o_THERM_EN,   // Thermocouple Enable output
    output o_UART_RX,    // UART RX output
    output o_UART_TX,    // UART TX output
    output o_X_DIR,      // X Direction output
    output o_X_EN,       // X Enable output
    output o_X_MAX,      // X Max output
    output o_X_MIN,      // X Min input
    output o_X_STEP,     // X Step output
    output o_Y_DIR,      // Y Direction output
    output o_Y_EN,       // Y Enable output
    output o_Y_MAX,      // Y Max output
    output o_Y_MIN,      // Y Min output
    output o_Y_STEP,     // Y Step output
    output o_Z_DIR,      // Z Direction output
    output o_Z_EN,       // Z Enable output
    output o_Z_MAX,      // Z Max output
    output o_Z_MIN,      // Z Min output
    output o_Z_STEP     // Z Step output
);
        
// Bypass mode control signals
reg bypass_mode_en = 1'b0;
reg [1:0] button_debounce = 2'b00;
wire button_press;
        
assign button_press = (~button_debounce[1] & button_debounce[0]); 
assign led0_g = bypass_mode_en;
assign led0_r = ~bypass_mode_en;

always @(posedge sysclk) begin
    button_debounce <= {button_debounce[0], btn0};
        if (button_press) begin
        bypass_mode_en <= ~bypass_mode_en; // invert the bits of the register
    end
end

// ------------------ BYPASS MUXs ------------------
assign o_D10        = bypass_mode_en ? i_D10        : 1'bz; 
assign o_D9         = bypass_mode_en ? i_D9         : 1'bz;
assign o_E0_DIR     = bypass_mode_en ? i_E0_DIR     : 1'bz;
assign o_E0_EN      = bypass_mode_en ? i_E0_EN      : 1'bz;
assign o_E0_STEP    = bypass_mode_en ? i_E0_STEP    : 1'bz;
assign o_UART_RX    = bypass_mode_en ? i_UART_RX    : 1'bz;
assign o_UART_TX    = bypass_mode_en ? i_UART_TX    : 1'bz;
assign o_X_DIR      = bypass_mode_en ? i_X_DIR      : 1'bz;
assign o_X_EN       = bypass_mode_en ? i_X_EN       : 1'bz;
assign o_X_MAX      = bypass_mode_en ? i_X_MAX      : 1'bz;
assign o_X_MIN      = bypass_mode_en ? i_X_MIN      : 1'bz;
assign o_X_STEP     = bypass_mode_en ? i_X_STEP     : 1'bz;
assign o_Y_DIR      = bypass_mode_en ? i_Y_DIR      : 1'bz;
assign o_Y_EN       = bypass_mode_en ? i_Y_EN       : 1'bz;
assign o_Y_MAX      = bypass_mode_en ? i_Y_MAX      : 1'bz;
assign o_Y_MIN      = bypass_mode_en ? i_Y_MIN      : 1'bz;
assign o_Y_STEP     = bypass_mode_en ? i_Y_STEP     : 1'bz;
assign o_Z_DIR      = bypass_mode_en ? i_Z_DIR      : 1'bz;
assign o_Z_EN       = bypass_mode_en ? i_Z_EN       : 1'bz;
assign o_Z_MAX      = bypass_mode_en ? i_Z_MAX      : 1'bz;
assign o_Z_MIN      = bypass_mode_en ? i_Z_MIN      : 1'bz;
assign o_Z_STEP     = bypass_mode_en ? i_Z_STEP     : 1'bz;

// Thermometer Enable output might combine two inputs or have a default state                               
assign o_THERM_EN   = bypass_mode_en ? (i_THERM0_SCL & i_THERM0_SDA) : 1'bz; // Example combining two inputs

endmodule
