const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("OptimizedHealthCare", function () {
  let healthcare, owner, doctor, patient;

  before(async function () {
    [owner, doctor, patient] = await ethers.getSigners();
    const OptimizedHealthCare = await ethers.getContractFactory("OptimizedHealthCare");
    healthcare = await OptimizedHealthCare.deploy();
    await healthcare.deployed();
  });

  it("Should register a patient", async function () {
    await healthcare.connect(patient).registerPatient("John Doe", "1990-01-01", "Male", "john@example.com");
    const patientInfo = await healthcare.getPatientInfo(patient.address);
    expect(patientInfo[0]).to.equal("John Doe");
  });

  it("Should register a doctor", async function () {
    await healthcare.connect(doctor).registerDoctor("Dr. Smith", "123-456-7890", "Cardiology");
    const doctorInfo = await healthcare.getDoctorInfo(doctor.address);
    expect(doctorInfo[0]).to.equal("Dr. Smith");
  });

  it("Should allow a patient to grant access to a doctor", async function () {
    await healthcare.connect(patient).grantAccess(doctor.address);
    const hasAccess = await healthcare.hasAccess(patient.address, doctor.address);
    expect(hasAccess).to.equal(true);
  });

  it("Should allow a patient to add a medical file", async function () {
    await healthcare.connect(patient).addFile("X-ray Report", "PDF", "Qm123456...");
    const files = await healthcare.getPatientFiles(patient.address);
    expect(files.length).to.equal(1);
    expect(files[0].fileName).to.equal("X-ray Report");
  });
});
