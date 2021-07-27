import matplotlib.pyplot as plt
import os
import fire

class Dataset:
    def __init__(self, directories):
        self.data = dict()
        for d in directories:
            self.readdata(d)
        print(self.data)
    def readdata(self, directory):
        cs = directory.split('_')[-1]
        slack, freq = self.readtiming(directory)
        power = self.readpower(directory)
        util = self.readutilization(directory)
        totalLUTs = util[0]
        logicLUTs = util[1]
        LUTRAM = util[2]
        SRLs = util[3]
        ffs = util[4]
        ramb36 = util[5]
        ramb18 = util[6]
        uram = util[7]
        dsps = util[8]
        self.readutilization(directory)
        self.data[cs] = [slack, freq, power, totalLUTs, logicLUTs, LUTRAM, SRLs, ffs, ramb36, ramb18, uram, dsps]
    def readtiming(self, directory):
        trep = directory + "/timing.txt"
        with open(trep, "r") as f:
            content = f.read()
            slack = float(content.split("\n")[-6][-20:].strip())
            maxfreq = 1/(1-slack) * 1000
        return slack, maxfreq
    def readpower(self, directory):
        prep = directory + "/power_report.txt"
        with open(prep, "r") as f:
            content = f.read()
            power = float(list(filter(lambda l : l.startswith("| qlearning_virtex |"), content.split("\n")))[0].split("|")[-2].strip())
        return power
    def readutilization(self, directory):
        urep = directory + "/utilization.txt"
        with open(urep, "r") as f:
            content = f.read()
            words = list(map(lambda w : int(w.strip()), list(filter(lambda l : l.startswith("| qlearning_virtex"), content.split("\n")))[0].split("|")[3:-1]))
        return words
    def getidx(self, i, subset=None):
        if subset == None:
            return [self.data["sw4"][i], self.data["sw6"][i], self.data["sw8"][i], self.data["sw10"][i], self.data["sw12"][i], self.data["sw14"][i], self.data["sw16"][i], self.data["sw18"][i]]
        else:
            return list(map(lambda sw : self.data[sw][i], subset))
    def getslack(self, subset=None):
        return self.getidx(0, subset=subset)
    def getfreqs(self, subset=None):
        return self.getidx(1, subset=subset)
    def getpower(self, subset=None):
        return self.getidx(2, subset=subset)
    def getpower_mw(self, subset=None):
        return list(map(lambda p : p * 1000, self.getpower(subset=subset)))
    def getluts(self, subset=None):
        return self.getidx(3, subset=subset)
    def getffs(self, subset=None):
        return self.getidx(7, subset=subset)
    def getramb36(self, subset=None):
        return self.getidx(8, subset=subset)
    def getramb18(self, subset=None):
        return self.getidx(9, subset=subset)
    def getattrib(self, attrib, subset=None):
        if attrib == "slack":
            return self.getslack(subset=subset)
        elif attrib == "freq":
            return self.getfreqs(subset=subset)
        elif attrib == "power":
            return self.getpower(subset=subset)
        elif attrib == "luts":
            return self.getluts(subset=subset)
        elif attrib == "ffs":
            return self.getluts(subset=subset)
        elif attrib == "ram36":
            return self.getramb36(subset=subset)
        elif attrib == "ram18":
            return self.getramb18(subset=subset)
        return []
    def getbram(self, subset=None):
        ramb18 = self.getramb18(subset=subset)
        ramb36 = self.getramb36(subset=subset)
        bram = [a/2+b for a,b in zip(ramb18, ramb36)]
        return bram
    def getbram_perc(self, subset=None):
        bram = self.getbram(subset=subset)
        print(bram)
        bram_perc = list(map(lambda b : float(b) / 2688.0 * 100, bram))
        print(bram_perc)
        return bram_perc

def loaddata():
    data = dict()

    template = "reports_{}_{}_{}_{}"

    seventhdir = "seventhrun"
    directories = list(filter(lambda d : os.path.isdir(seventhdir + "/" + d) and d.startswith("reports"), os.listdir(seventhdir)))

    for s in ["ql", "sarsa"]:
        for a in ["singleram", "actionrams"]:
            for p in ["random", "egreedy"]:
                for aw in ["aw2", "aw3"]:
                    directory_prefix = template.format(s,a,p,aw)
                    datadirs = list(map(lambda dd : seventhdir + "/" + dd, filter(lambda d : d.startswith(directory_prefix), directories)))
                    print(seventhdir + "/" + directory_prefix)
                    dataset = Dataset(datadirs)
                    data[seventhdir + "/" + directory_prefix] = dataset

    eighthdir = "eighthrun"
    directories = list(filter(lambda d : os.path.isdir(eighthdir + "/" + d) and d.startswith("reports"), os.listdir(eighthdir)))

    for s in ["ql", "sarsa"]:
        for a in ["singleram", "actionrams"]:
            for p in ["random", "egreedy"]:
                for aw in ["aw2", "aw3"]:
                    directory_prefix = template.format(s,a,p,aw)
                    datadirs = list(map(lambda dd : eighthdir + "/" + dd, filter(lambda d : d.startswith(directory_prefix), directories)))
                    print(eighthdir + "/" + directory_prefix)
                    dataset = Dataset(datadirs)
                    data[eighthdir + "/" + directory_prefix] = dataset
    return data

def main():
    template = "reports_{}_{}_{}_{}"
    # sw 6 8 10 12 16 18
    qtaccel_aw2_freq = [189, 187, 187, 186, 175, 156]
    qtaccel_aw2_freq_sarsa = [181, 180, 180, 179, 171, 150]
    qtaccel_aw3_bram = [0.02, 0.09, 0.32, 1.34, 4.85, 19.42, 78.12]
    qtaccel_power = [75, 60, 75, 80, 110, 190, 225]
    faq_power_achievable = list(map(lambda x : x / 1000, [93, 93, 107, 156, 319, 996, 2184, 5855]))
    subset = ["sw6", "sw8", "sw10", "sw12", "sw16", "sw18"]
    subset2 = ["sw6", "sw8", "sw10", "sw12", "sw14", "sw16", "sw18"]
    data = loaddata()

    faq3m = data["seventhrun/reports_ql_actionrams_random_aw3"]
    faq3s = data["seventhrun/reports_ql_singleram_random_aw3"]
    faq4m = data["eighthrun/reports_ql_actionrams_random_aw3"]
    faq4s = data["eighthrun/reports_ql_singleram_random_aw3"]

    palette = ["#042A2B", "#5EB1BF", "#CDEDF6", "#EF7B45", "#D84727"]

    fig,ax = plt.subplots()
    ticks = [1,5,9,13,17,21,25,29]
    group1 = list(map(lambda x : x - 1.2, ticks))
    group2 = list(map(lambda x : x - 0.4, ticks))
    group3 = list(map(lambda x : x + 0.4, ticks))
    group4 = list(map(lambda x : x + 1.2, ticks))
    ax.bar(group1, faq3m.getfreqs(), label="FAQ-3M", color=palette[0])
    ax.bar(group2, faq4m.getfreqs(), label="FAQ-4M", color=palette[1])
    ax.bar(group3, faq3s.getfreqs(), label="FAQ-3S", color=palette[3])
    ax.bar(group4, faq4s.getfreqs(), label="FAQ-4S", color=palette[4])
    ax.set_xticks(ticks)
    ax.set_xticklabels(["16","64", "256", "1024", "4096", str(2**14), str(2**16), str(2**18)])
    ax.legend()
    plt.xlabel("Number of States |S|")
    plt.ylabel("Throughput [MSps]")
    plt.title("Throughput Evaluation FAQ 1")
    plt.savefig("plots/faq_throughput.pdf")

    faqSG = data["eighthrun/reports_sarsa_singleram_egreedy_aw3"]
    faqSR = data["eighthrun/reports_sarsa_singleram_random_aw3"]
    faqQG = data["eighthrun/reports_ql_singleram_egreedy_aw3"]
    faqQR = data["eighthrun/reports_ql_singleram_random_aw3"]

    fig,ax = plt.subplots()
    group1 = list(map(lambda x : x - 1.2, ticks))
    group2 = list(map(lambda x : x - 0.4, ticks))
    group3 = list(map(lambda x : x + 0.4, ticks))
    group4 = list(map(lambda x : x + 1.2, ticks))
    ax.bar(group1, faqSG.getfreqs(), label="FAQ-SG", color=palette[0])
    ax.bar(group2, faqSR.getfreqs(), label="FAQ-SR", color=palette[1])
    ax.bar(group3, faqQG.getfreqs(), label="FAQ-QG", color=palette[3])
    ax.bar(group4, faqQR.getfreqs(), label="FAQ-QR", color=palette[4])
    ax.set_xticks(ticks)
    ax.set_xticklabels(["16","64", "256", "1024", "4096", str(2**14), str(2**16), str(2**18)])
    ax.legend()
    plt.xlabel("Number of States |S|")
    plt.ylabel("Throughput [MSps]")
    plt.title("Throughput Evaluation FAQ 2")
    plt.savefig("plots/faq_throughput_2.pdf")


    faq4 = data["eighthrun/reports_ql_singleram_random_aw2"]
    faq8 = data["eighthrun/reports_ql_singleram_random_aw3"]

    fig,ax = plt.subplots()
    ticks = [1,5,9,13,17,21,25,29]
    group1 = list(map(lambda x : x - 0.8, ticks))
    group2 = list(map(lambda x : x , ticks))
    group3 = list(map(lambda x : x + 0.8, ticks))
    ax.bar(group1, faq8.getluts(), label="LUTs", color=palette[0])
    ax.bar(group2, faq8.getffs(), label="FFs", color=palette[1])
    ax.bar(group3, faq8.getbram(), label="BRAM", color=palette[4])
    ax.plot([],[],label="Power",color="#306B34")
    ax.set_xticks(ticks)
    ax.set_xticklabels(["16","64", "256", "1024", "4096", str(2**14), str(2**16), str(2**18)])
    ax.set_ylabel("Resource Utilization")
    ax.legend()

    ax2 = ax.twinx()
    ax2.plot(ticks, faq_power_achievable, color="#306B34", label="Power")
    #ax2.legend(loc=1)
    ax2.set_ylabel("Power [W]")

    #plt.legend()
    plt.xlabel("Number of States |S|")
    plt.title("Resource Utilization and Power Consumption")
    plt.savefig("plots/faq_resources.pdf")

    fig,ax = plt.subplots()
    ticks = [1,4,7,10,13,16]
    group1 = list(map(lambda x : x - 0.8, ticks))
    group2 = list(map(lambda x : x , ticks))
    group3 = list(map(lambda x : x + 0.8, ticks))
    ax.bar(group1, faq4.getfreqs(subset=subset), label="FAQ |A|=4", color=palette[0])
    ax.bar(group2, faq8.getfreqs(subset=subset), label="FAQ |A|=8", color=palette[1])
    ax.bar(group3, qtaccel_aw2_freq, label="QTAccel", color=palette[4])
    ax.set_xticks(ticks)
    ax.set_xticklabels(["64", "256", "1024", "4096", str(2**16), str(2**18)])
    ax.legend()
    plt.xlabel("Number of States |S|")
    plt.ylabel("Throughput [MSps]")
    plt.title("Timing Comparison with QTAccel")
    plt.savefig("plots/faq_qtaccel_throughput.pdf")

    fig,ax = plt.subplots()
    ticks = [1,3,5,7,9,11,13]
    group1 = list(map(lambda x : x - 0.4, ticks))
    group2 = list(map(lambda x : x + 0.4, ticks))
    ax.bar(group1, faq8.getbram_perc(subset=subset2), label="FAQ", color="#1D3557")
    ax.bar(group2, qtaccel_aw3_bram, label="QTAccel", color="#E63946")
    ax.plot([],[],label="FAQ Power",color="#306B34")
    ax.plot([],[],label="QTAccel Power",color="#C3EB78")
    ax.set_xticks(ticks)
    ax.set_xticklabels(["64", "256", "1024", "4096", str(2**14), str(2**16), str(2**18)])
    ax.set_ylabel("BRAM Utilization [%]")
    ax.legend()

    ax2 = ax.twinx()
    ax2.plot(ticks, faq8.getpower_mw(subset=subset2), color="#306B34", label="FAQ Power")
    ax2.plot(ticks, qtaccel_power, color="#C3EB78", label="QTAccel Power")
    #ax2.legend(loc=1)
    ax2.set_ylabel("Power [mW]")

    plt.xlabel("Number of States |S|")
    #plt.ylabel("BRAM utilization [%]")
    plt.title("BRAM Utilization compared to QTAccel")
    plt.savefig("plots/faq_qtaccel_bram_power.pdf")
    

    fig,ax = plt.subplots()
    ticks = [1,3,5,7,9,11,13]
    group1 = list(map(lambda x : x - 0.4, ticks))
    group2 = list(map(lambda x : x + 0.4, ticks))
    ax.bar(group1, faq8.getbram_perc(subset=subset2), label="FAQ", color="#1D3557")
    ax.bar(group2, qtaccel_aw3_bram, label="QTAccel", color="#E63946")
    ax.set_xticks(ticks)
    ax.set_xticklabels(["64", "256", "1024", "4096", str(2**14), str(2**16), str(2**18)])
    ax.set_ylabel("BRAM Utilization [%]")
    ax.legend()

    plt.xlabel("Number of States |S|")
    #plt.ylabel("BRAM utilization [%]")
    plt.title("BRAM Utilization compared to QTAccel")
    plt.savefig("plots/faq_qtaccel_bram.pdf")

    #dataset = data["seventhrun/reports_ql_singleram_random_aw2"]
    #dataset2 = data["seventhrun/reports_ql_singleram_random_aw3"]
    #dataset3 = data["seventhrun/reports_ql_actionrams_random_aw2"]
    #dataset4 = data["seventhrun/reports_ql_actionrams_random_aw3"]

    #fig,ax = plt.subplots()
    #ticks = [1,3,5,7,9,11]
    #group1 = list(map(lambda x : x - 0.4, ticks))
    #group2 = list(map(lambda x : x + 0.4, ticks))
    #ax.bar(group1, dataset.getfreqs(subset=subset), label="FAQ", color="#1D3557")
    #ax.bar(group2, qtaccel_aw2_freq, label="QTAccel", color="#E63946")
    #ax.set_xticks(ticks)
    #ax.set_xticklabels(["64", "256", "1024", "4096", str(2**16), str(2**18)])
    #ax.legend()
    #plt.xlabel("Number of States |S|")
    #plt.ylabel("Throughput [MHz]")
    #plt.title("Timing Comparison with QTAccel")
    #plt.savefig("plots/cmp_qtaccel_timing_single.pdf")

    #fig,ax = plt.subplots()
    #ticks = [1,4,7,10,13,16]
    #group1 = list(map(lambda x : x - 0.8, ticks))
    #group2 = list(map(lambda x : x , ticks))
    #group3 = list(map(lambda x : x + 0.8, ticks))
    #ax.bar(group1, dataset.getfreqs(subset=subset), label="FAQ |A|=4", color="#1D3557")
    #ax.bar(group2, dataset2.getfreqs(subset=subset), label="FAQ |A|=8", color="#A8DADC")
    #ax.bar(group3, qtaccel_aw2_freq, label="QTAccel", color="#E63946")
    #ax.set_xticks(ticks)
    #ax.set_xticklabels(["64", "256", "1024", "4096", str(2**16), str(2**18)])
    #ax.legend()
    #plt.xlabel("Number of States |S|")
    #plt.ylabel("Throughput [MHz]")
    #plt.title("Timing Comparison with QTAccel")
    #plt.savefig("plots/cmp_qtaccel_timing2_single.pdf")

    #fig,ax = plt.subplots()
    #ticks = [1,3,5,7,9,11]
    #group1 = list(map(lambda x : x - 0.4, ticks))
    #group2 = list(map(lambda x : x + 0.4, ticks))
    #ax.bar(group1, dataset3.getfreqs(subset=subset), label="FAQ", color="#1D3557")
    #ax.bar(group2, qtaccel_aw2_freq, label="QTAccel", color="#E63946")
    #ax.set_xticks(ticks)
    #ax.set_xticklabels(["64", "256", "1024", "4096", str(2**16), str(2**18)])
    #ax.legend()
    #plt.xlabel("Number of States |S|")
    #plt.ylabel("Throughput [MHz]")
    #plt.title("Timing Comparison with QTAccel")
    #plt.savefig("plots/cmp_qtaccel_timing.pdf")

    #fig,ax = plt.subplots()
    #ticks = [1,4,7,10,13,16]
    #group1 = list(map(lambda x : x - 0.8, ticks))
    #group2 = list(map(lambda x : x , ticks))
    #group3 = list(map(lambda x : x + 0.8, ticks))
    #ax.bar(group1, dataset3.getfreqs(subset=subset), label="FAQ |A|=4", color="#1D3557")
    #ax.bar(group2, dataset4.getfreqs(subset=subset), label="FAQ |A|=8", color="#A8DADC")
    #ax.bar(group3, qtaccel_aw2_freq, label="QTAccel", color="#E63946")
    #ax.set_xticks(ticks)
    #ax.set_xticklabels(["64", "256", "1024", "4096", str(2**16), str(2**18)])
    #ax.legend()
    #plt.xlabel("Number of States |S|")
    #plt.ylabel("Throughput [MHz]")
    #plt.title("Timing Comparison with QTAccel")
    #plt.savefig("plots/cmp_qtaccel_timing2.pdf")

    #fig,ax = plt.subplots()
    #dataset = data["seventhrun/reports_ql_actionrams_random_aw2"]
    #ticks = [1,3,5,7,9,11,13,15]
    #group1 = list(map(lambda x : x - 0.4, ticks))
    #group2 = list(map(lambda x : x + 0.4, ticks))
    #ax.bar(group1, dataset.getffs(), label="FFs", color="#1D3557")
    #ax.bar(group2, dataset.getluts(), label="LUTs", color="#E63946")
    #ax.set_xticks(ticks)
    #ax.set_xticklabels(["16", "64", "256", "1024", "4096", str(2**14), str(2**16), str(2**18)])
    #ax.legend()
    #plt.xlabel("Number of States |S|")
    #plt.ylabel("Amount Utilized")
    #plt.title("Resource Utilization")
    #plt.savefig("plots/utilization.pdf")

    #fig,ax = plt.subplots()
    #dataset = data["seventhrun/reports_ql_actionrams_random_aw2"]
    #ticks = [1,3,5,7,9,11,13,15]
    #ax.bar(ticks, dataset.getbram(), label="BRAMs", color="#1D3557")
    #ax.set_xticks(ticks)
    #ax.set_xticklabels(["16", "64", "256", "1024", "4096", str(2**14), str(2**16), str(2**18)])
    #ax.legend()
    #plt.xlabel("Number of States |S|")
    #plt.ylabel("Amount Utilized")
    #plt.title("BRAM Utilization")
    #plt.savefig("plots/bram.pdf")

    #fig,ax = plt.subplots()
    #dataset = data["seventhrun/reports_ql_actionrams_random_aw2"]
    #ticks = [1,3,5,7,9,11,13,15]
    #ax.bar(ticks, dataset.getpower(), label="Power", color="#1D3557")
    #ax.set_xticks(ticks)
    #ax.set_xticklabels(["16", "64", "256", "1024", "4096", str(2**14), str(2**16), str(2**18)])
    #ax.legend()
    #plt.xlabel("Number of States |S|")
    #plt.ylabel("Power [mW]")
    #plt.title("Power")
    #plt.savefig("plots/power.pdf")








if __name__ == "__main__":
    fire.Fire(main)
