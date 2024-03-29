module CharacteristicsAppHelper
	def check_valid_characteristics_app(characteristics_app)
		if characteristics_app.nil?
			respond_to do |format|
				format.html { redirect_to :back, flash: {error: "Cannot access that characteristics app" } }
				format.mobile { render json: {status: "failure", failure_reason: "INVALID_CHARACTERISTICS_APP"} }
				format.js { }
			end
		end
	end
	
	def check_characteristics_app_exists(characteristics_app)
		if !characteristics_app.nil?
			respond_to do |format|
				format.html { redirect_to :back, flash: {error: "Cannot create a new characteristics app, one already exists" } }
				format.mobile { render json: {status: "failure", failure_reason: "APP_EXISTS"} }
				format.js { }
			end
		end
	end
end