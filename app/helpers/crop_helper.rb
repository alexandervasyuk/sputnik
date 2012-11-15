module CropHelper
  def set_temp_profile_pic(upload)
    session[:temp_pic] = Rails.root.join('public', 'uploads', upload.original_filename)
      
    File.open(Rails.root.join('public', 'uploads', upload.original_filename), 'wb') do |file|
      file.write(upload.read)
    end
  end
  
  def clear_temp_profile_pic
    if (!session[:temp_pic].nil? && File.exist?(session[:temp_pic]))
      File.delete(session[:temp_pic])
    end
  end
end