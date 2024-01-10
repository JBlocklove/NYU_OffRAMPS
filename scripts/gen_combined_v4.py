import fileinput
import re
import random

# all examples run in the middle 75%
# blob means it will deposit a blob at the end location before moving on, false means it will extrude the extra on the next extrusion

infilename = 'PI3MK3M_UM2_Tensile_test_specimen_fine_resolution_cntr_flat_ascii.gcode'
outs = [
    {'name' : '100_cycle_blob_false', 'cycles':100, 'blob':False},
    #{'name' : '20_cycle_blob_false', 'cycles':20, 'blob':False},
    #{'name' : '10_cycle_blob_false', 'cycles':10, 'blob':False},
    #{'name' : '5_cycle_blob_false', 'cycles':5, 'blob':False},

    {'name' : 'reduction_0p98', 'reduction_mul':0.98},
    #{'name' : 'reduction_0p9', 'reduction_mul':0.9},
    #{'name' : 'reduction_0p8', 'reduction_mul':0.8},
    #{'name' : 'reduction_0p5', 'reduction_mul':0.5},
]

fi = open(infilename, "r")

enabled = True
skip = False
count = 0

rex = re.compile("G1 (F[0-9.]+)? ?X([0-9.]+) Y([0-9.]+) E([0-9.]+)\n")

lines = fi.readlines()
fi.close()

for out in outs:
    fo = open(out['name'] + '.gcode', "w+")
    if 'reduction_mul' in out:
        def modify_e(match):
            val = match.group()
            num = float(val[1:])
            return "E" + str(num * out['reduction_mul'])

        for line in lines:
            if line[0:2] == "G1":
                line = re.sub(r'E[0-9.]+', modify_e, line)
            fo.write(line)


    else:
        for line in lines:
            #if line[0:3] == "M73":
            #    percentages = re.findall(r'P[0-9.]+', line)
            #    if len(percentages) == 1:
            #        percent = float(percentages[0][1:])
            #        if percent >= 25 and percent <= 75:
            #            enabled = True
            #        else:
            #            enabled = False

            #if skip:
            #    if line[0:2] == "G1" and enabled:
            #        line = ";okay next (skipped)\n" + line
            #    skip = False
            if enabled:
                if line[0:2] == "G1":
                    count = count + 1
                    if count >= out['cycles']: #every fourth line is changed
                        count = 0
                        res = rex.search(line)
                        if res:
                            f = res.group(1)
                            if f is not None:
                                x = res.group(2)
                                y = res.group(3)
                                e = res.group(4)
                                if out['blob']:
                                    line = ";defect next\nG0 " + f + " " + "X" + x + " " + "Y" + y + "\n" + "G1 E" + e + "\n"
                                else:
                                    line = ";defect next\nG0 " + f + " " + "X" + x + " " + "Y" + y + "\n" # + "G1 " + f + " " + "X" + x + " " + "Y" + y + " " + "E" + e + "\n"
                            else:
                                f = None
                                x = res.group(2)
                                y = res.group(3)
                                e = res.group(4)
                                if out['blob']:
                                    line = ";defect next\nG0 X" + x + " " + "Y" + y + "\n" + "G1 E" + e + "\n"
                                else:
                                    line = ";defect next\nG0 X" + x + " " + "Y" + y + "\n" #+ "G1 X" + x + " " + "Y" + y + " " + "E" + e + "\n"

                            #print(line)
                            #skip = True
                            #line = re.sub(r'E[0-9.]+\n', modify_e, line)
                            #print(line)
                        else:
                            line = ";okay next (didn't match RE)\n" + line
                    else:
                        line = ";okay next (not selected)\n" + line
            fo.write(line)
    fo.close()
    print("Done " + out['name'])
