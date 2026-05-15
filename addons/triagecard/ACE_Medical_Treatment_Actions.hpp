class ace_medical_treatment_actions {
	class CheckPulse;
	class LNX_DD1380_TCCC_Open : CheckPulse {
		displayName = "Open TCCC Card";
		displayNameProgress = "Opening Card...";
		icon = "";
		treatmentTime = 1;
		allowedSelections[] = {"Head", "Body"};
		allowSelfTreatment = 1;
		condition = "true";
		callbackSuccess = QFUNC(openCard);
	};
};
