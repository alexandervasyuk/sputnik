module Paperclip
  class Cropper < Thumbnail
    def transformation_command      
      if crop_command
        crop_command
      else
        super
      end
    end
    
    def crop_command
      puts @attachment.instance
      
      target = @attachment.instance
      if target.cropping?
        "-crop '#{target.crop_w.to_i}x#{target.crop_h.to_i}+#{target.crop_x.to_i}+#{target.crop_y.to_i}' -scale 75x75\!"
      end
    end
  end
end