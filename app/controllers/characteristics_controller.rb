class CharacteristicsController < ApplicationController
	def create
		@micropost = Micropost.find(params[:characteristic][:micropost_id])
		
		@characteristic = @micropost.characteristics.build(params[:characteristic])
		
		@characteristic.save
		
		respond_to do |format|
			format.html { redirect_to :back }
			format.js
		end
	end
	
	def update
		
	end
	
	def destroy
		
	end
end