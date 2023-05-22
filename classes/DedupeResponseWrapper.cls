public without sharing class DedupeResponseWrapper {
    
	public class Loans {
		public Loan loan;
	}

	public class KycIds {
		public String pan;
		public String passport;
		public String aadhaar;
		public String voterId;
		public String drivingLicense;
	}

	public List<Applicant_Z> applicant;

	public class Loan {
		public String lan;
		public String lanstatus;
		public String applicationNo;
		public String applicationStatus;
		public String applicantType;
		public String branchCode;
		public String branchName;
		public String firstName;
		public String lastName;
		public String gender;
		public String fatherName;
		public String motherName;
		public String spouseName;
		public String dob;
		public String mobileNo;
		public ResidenceAddress residenceAddress;
	}

	public class Matches {
		public Match match;
	}

	public class Applicant_Z {
		public Applicant applicant;
	}

	public class ResidenceAddress {
		public String addressLine1;
		public String addressLine2;
		public String addressLine3;
		public String city;
		public String district;
		public String state;
		public String pincode;
	}

	public class Applicant {
		public String applicantId;
		public List<Matches> matches;
	}

	public class Match {
		public String customerRelId;
		public String cifId;
		public String source;
		public List<Loans> loans;
		public KycIds kycIds;
	}   
}