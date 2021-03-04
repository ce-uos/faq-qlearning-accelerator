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
            maxfreq = 1/(6-slack) * 1000
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
            return map(lambda sw : self.data[sw][i], subset)
    def getslack(self, subset=None):
        return self.getidx(0, subset=subset)
    def getfreqs(self, subset=None):
        return self.getidx(1, subset=subset)
    def getpower(self, subset=None):
        return self.getidx(2, subset=subset)
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

def loaddata():
    data = dict()

    template = "reports_{}_{}_{}_{}"

    # sw 6 8 10 12 16 18
    qtaccel_aw2_freq = [189, 187, 187, 186, 175, 156]
    qtaccel_aw2_freq_sarsa = [181, 180, 180, 179, 171, 150]

    directories = list(filter(lambda d : os.path.isdir(d) and d.startswith("reports"), os.listdir('.')))

    for s in ["ql", "sarsa"]:
        for a in ["singleram", "actionrams"]:
            for p in ["random", "egreedy"]:
                for aw in ["aw2", "aw3"]:
                    directory_prefix = template.format(s,a,p,aw)
                    datadirs = list(filter(lambda d : d.startswith(directory_prefix), directories))
                    print(directory_prefix)
                    dataset = Dataset(datadirs)
                    data[directory_prefix] = dataset
    return data

def main(makeplots=False, dataset=None, attrib=None, subset=None):
    if dataset != None and attrib != None:
        data = loaddata()
        if subset != None:
            subset = subset.split(",")
        print(data[dataset].getattrib(attrib, subset=subset))

    if makeplots:
        template = "reports_{}_{}_{}_{}"
        data = loaddata()
        print(data["reports_ql_singleram_random_aw3"].getfreqs())
        for s in ["ql", "sarsa"]:
            for a in ["singleram", "actionrams"]:
                for p in ["random", "egreedy"]:
                    for aw in ["aw2", "aw3"]:
                        directory_prefix = template.format(s,a,p,aw)

                        # timing
                        plt.figure()
                        plt.bar([1,3,5,7,9,11,13,15], data[directory_prefix].getfreqs())
                        plt.title(directory_prefix)
                        plt.savefig("plots/timing_" + directory_prefix + ".png")

                        # power
                        plt.figure()
                        plt.bar([1,3,5,7,9,11,13,15], data[directory_prefix].getpower())
                        plt.title(directory_prefix)
                        plt.savefig("plots/power_" + directory_prefix + ".png")


if __name__ == "__main__":
    fire.Fire(main)
