classdef SplashScreen < hgsetget
    %SplashScreen  create a splashscreen
    %
    %   s = SplashScreen(title,imagefile) creates a splashscreen using
    %   the specified image. The title is the name of the window as shown
    %   in the task-bar. Use "delete(s)" to remove it. Note that images
    %   must be in PNG, GIF or JPEG format. Use the addText method to add
    %   text to your splashscreen
    %
    %   Examples:
    %   s = SplashScreen( 'Splashscreen', 'example_splash.png', ...
    %                     'ProgressBar', 'on', ...
    %                     'ProgressPosition', 5, ...
    %                     'ProgressRatio', 0.4 )
    %   s.addText( 30, 50, 'My Cool App', 'FontSize', 30, 'Color', [0 0 0.6] )
    %   s.addText( 30, 80, 'v1.0', 'FontSize', 20, 'Color', [0.2 0.2 0.5] )
    %   s.addText( 300, 270, 'Loading...', 'FontSize', 20, 'Color', 'white' )
    %   delete( s )
    %
    %   See also: SplashScreen/addText
    
    %   Copyright 2008-2011 The MathWorks, Inc.
    %   Revision: 1.1
    
    %% Public properties
    properties
        Visible = 'on'       % Is the splash-screen visible on-screen [on|off]
        Border = 'off'        % Is the edge pixel darkened to form a border [on|off]
        ProgressBar = 'on'  % Is the progress bar visible [on|off]
        ProgressPosition = 10% Height (in pixels) above the bottom of the window for the progress bar
        ProgressRatio = 0    % The ratio shown on the progress bar (in range 0 to 1)
        Tag = ''             % User tag for this object
    end % Public properties
    
    %% Read-only properties
    properties ( GetAccess = public, SetAccess = private )
        Width = 0            % Width of the window
        Height = 0           % Height of the window
    end % Read-only properties
    
    %% Private properties
    properties ( Access = private )
        Icon = []
        BufferedImage = []
        OriginalImage = []
        Label = []
        Frame = []
    end % Read-only properties
    
    %% Public methods
    methods
        
        function obj = SplashScreen( title, imagename, varargin )
            % Construct a new splash-screen object
            if nargin<2
                error('SplashScreen:BadSyntax', 'Syntax error. You must supply both a window title and imagename.' );
            end
            % First try to load the image as an icon
            fullname = iMakeFullName( imagename );
            if exist(fullname,'file')~=2
                % Try on the path
                fullname = which( imagename );
                if isempty( fullname )
                    error('SplashScreen:BadFile', 'Image ''%s'' could not be found.', imagename );
                end
            end
            % Create the interface
            obj.createInterfaceComponents( title, fullname );
            obj.updateAll();
            
            % Set any user-specified properties
            for ii=1:2:nargin-2
                param = varargin{ii};
                value = varargin{ii+1};
                obj.(param) = value;
            end
            
            % If the user hasn't overridden the default, finish by putting
            % it onscreen
            if strcmpi(obj.Visible,'on')
                obj.Frame.setVisible(true);
            end
        end % SplashScreen
        
        function addText( obj, x, y, text, varargin )
            %addText  Add some text to the background image
            %
            %   S.addText(X,Y,STR,...) adds some text to the splashscreen S
            %   showing the string STR. The text is located at pixel
            %   coordinates [X,Y]. Additional options can be set using
            %   parameter value pairs and include:
            %   'Color'      the font color (e.g. 'r' or [r g b])
            %   'FontSize'   the text size (in points)
            %   'FontName'   the name of the font to sue (default 'Arial')
            %   'FontAngle'  'normal' or 'italic'
            %   'FontWeight' 'normal' or 'bold'
            %   'Shadow'     'on' or 'off' (default 'on')
            %
            %   Examples:
            %   s = SplashScreen( 'Splashscreen', 'example_splash.png' );
            %   s.addText( 30, 50, 'My Cool App', 'FontSize', 30, 'Color', [0 0 0.6] )
            %
            %   See also: SplashScreen
            
            % We write into the original image so that the text is
            % permanent
            gfx = obj.OriginalImage.getGraphics();
            
            % Set the font size etc
            [font,color,shadow] = parseFontArguments( varargin{:} );
            gfx.setFont( font );
            
            % Switch on anti-aliasing
            gfx.setRenderingHint( java.awt.RenderingHints.KEY_ANTIALIASING, java.awt.RenderingHints.VALUE_ANTIALIAS_ON );
            
            % Draw the text semi-transparent as a shadow
            if shadow
                gfx.setPaint( java.awt.Color.black );
                ac = java.awt.AlphaComposite.getInstance( java.awt.AlphaComposite.SRC_OVER, 0.3 );
                gfx.setComposite( ac );
                gfx.drawString( text, x+1, y+2 );
                ac = java.awt.AlphaComposite.getInstance( java.awt.AlphaComposite.SRC_OVER, 0.5 );
                gfx.setComposite( ac );
                gfx.drawString( text, x, y+1 );
                ac = java.awt.AlphaComposite.getInstance( java.awt.AlphaComposite.SRC_OVER, 0.7 );
                gfx.setComposite( ac );
                gfx.drawString( text, x+1, y+1 );
            end
            
            % Now the text itself
            gfx.setPaint( color );
            ac = java.awt.AlphaComposite.getInstance( java.awt.AlphaComposite.SRC_OVER, 1.0 );
            gfx.setComposite( ac );
            gfx.drawString( text, x, y );
            
            
            % Now update everything else
            obj.updateAll();
        end % addText
        
        function delete(obj)
            %delete  destroy this object and close all graphical components
            if ~isempty(obj.Frame)
                dispose(obj.Frame);
            end
        end % delete
    end % Public methods
    
    %% Data-access methods
    methods
        
        function val = get.Width(obj)
            if isempty(obj.Icon)
                val = 0;
            else
                val = obj.Icon.getIconWidth();
            end
        end % get.Width
        
        function val = get.Height(obj)
            if isempty(obj.Icon)
                val = 0;
            else
                val = obj.Icon.getIconHeight();
            end
        end % get.Height
        
        function set.Visible(obj,val)
            if ~ischar( val ) || ~any( strcmpi( {'on','off'}, val ) )
                error( 'SplashScreen:BadValue', 'Property ''ProgressBar'' must be ''on'' or ''off''' );
            end
            obj.Visible = lower( val );
            obj.Frame.setVisible( strcmpi(val,'ON') ); %#ok<MCSUP>
        end % set.Visible
        
        function set.Border(obj,val)
            if ~ischar( val ) || ~any( strcmpi( {'on','off'}, val ) )
                error( 'SplashScreen:BadValue', 'Property ''Border'' must be ''on'' or ''off''' );
            end
            obj.Border = val;
            obj.updateAll();
        end % set.Border
        
        function set.ProgressBar(obj,val)
            if ~ischar( val ) || ~any( strcmpi( {'on','off'}, val ) )
                error( 'SplashScreen:BadValue', 'Property ''ProgressBar'' must be ''on'' or ''off''' );
            end
            obj.ProgressBar = val;
            obj.updateProgressBar();
        end % set.ProgressBar
        
        function set.ProgressRatio(obj,val)
            if ~isnumeric( val ) || ~isscalar( val ) || val<0 || val > 1
                error( 'SplashScreen:BadValue', 'Property ''ProgressRatio'' must be a scalar between 0 and 1' );
            end
            obj.ProgressRatio = val;
            obj.updateProgressBar();
        end % set.ProgressRatio
        
        function set.ProgressPosition(obj,val)
            if ~isnumeric( val ) || ~isscalar( val ) || val<1 || val > obj.Height %#ok<MCSUP>
                error( 'SplashScreen:BadValue', 'Property ''ProgressPosition'' must be a vertical position inside the window' );
            end
            obj.ProgressPosition = val;
            obj.updateAll();
        end % set.ProgressPosition
        
        function set.Tag(obj,val)
            if ~ischar( val )
                error( 'SplashScreen:BadValue', 'Property ''Tag'' must be a character array' );
            end
            obj.Tag = val;
        end % set.Tag
        
    end % Data-access methods
    
    
    %% Private methods
    methods ( Access = private )
        
        function createInterfaceComponents( obj, title, imageFile )
            import javax.swing.*;
            
            % Load the image
            jImFile = java.io.File( imageFile );
            try
                obj.OriginalImage = javax.imageio.ImageIO.read( jImFile );
            catch err
                error('SplashScreen:BadFile', 'Image ''%s'' could not be loaded.', imageFile );
            end
            % Read it again into the copy we'll draw on
            obj.BufferedImage = javax.imageio.ImageIO.read( jImFile );
            
            % Create the icon
            obj.Icon = ImageIcon( obj.BufferedImage );
            
            % Create the frame and fill it with the image
            obj.Frame = JFrame( title );
            obj.Frame.setUndecorated( true );
            obj.Label = JLabel( obj.Icon );
            p = obj.Frame.getContentPane();
            p.add( obj.Label );
            
            % Old code start here:
            % Resize and reposition the window
            obj.Frame.setSize( obj.Icon.getIconWidth(), obj.Icon.getIconHeight() );
            %pos = get(0,'MonitorPositions');
            %x0 = pos(1,1) + (pos(1,3)-obj.Icon.getIconWidth())/2;
            %y0 = pos(1,2) + (pos(1,4)-obj.Icon.getIconHeight())/2;
            %obj.Frame.setLocation( x0, y0 );
            % New Code starts here:
            
            set(0,'Units','pixels')
            screensize = get(0,'ScreenSize');
            
            w = obj.Frame.getWidth();
            h = obj.Frame.getHeight();
            x0 = ceil((screensize(3)-w)/2);
            y0 = ceil((screensize(4)-h)/2);

            obj.Frame.setLocation( x0, y0 );
            
        end % createInterfaceComponents
        
        function updateAll( obj )
            % Update the entire image
            
            % Copy in the original
            w = obj.Frame.getWidth();
            h = obj.Frame.getHeight();
            gfx = obj.BufferedImage.getGraphics();
            gfx.drawImage( obj.OriginalImage, 0, 0, w, h, 0, 0, w, h, [] );
            
            % Maybe draw a border
            if strcmpi( obj.Border, 'on' )
                % Switch on anti-aliasing
                gfx.setRenderingHint( java.awt.RenderingHints.KEY_ANTIALIASING, java.awt.RenderingHints.VALUE_ANTIALIAS_ON );
                % Draw a semi-transparent rectangle for the background
                ac = java.awt.AlphaComposite.getInstance( java.awt.AlphaComposite.SRC_OVER, 0.8 );
                gfx.setComposite( ac );
                gfx.setPaint( java.awt.Color.black );
                gfx.drawRect( 0, 0, w-1, h-1 );
            end
            
            obj.updateProgressBar();
        end % updateAll
        
        function updateProgressBar( obj )
            % Update the progressbar and other bits
            
            % First paint over the progressbar area with the original image
            gfx = obj.BufferedImage.getGraphics();
            border = 20;
            size = 15;
            w = obj.Frame.getWidth();
            h = obj.Frame.getHeight();
            py = obj.ProgressPosition;
            x1 = 1;
            y1 = h-py-size-1;
            x2 = w-2;
            y2 = h-py;
            gfx.drawImage( obj.OriginalImage, x1, y1, x2, y2, x1, y1, x2, y2, [] );
            
            if strcmpi( obj.ProgressBar, 'on' )
                % Draw the progress bar over the image
                
                % Switch on anti-aliasing
                gfx.setRenderingHint( java.awt.RenderingHints.KEY_ANTIALIASING, java.awt.RenderingHints.VALUE_ANTIALIAS_ON );
                % Draw a semi-transparent rectangle for the background
                ac = java.awt.AlphaComposite.getInstance( java.awt.AlphaComposite.SRC_OVER, 0.25 );
                gfx.setComposite( ac );
                gfx.setPaint( java.awt.Color.black );
                gfx.fillRoundRect( border, h-py-size, w-2*border, size, size, size );
                % Now draw the foreground bit
                progWidth = (w-2*border-2) * obj.ProgressRatio;
                ac = java.awt.AlphaComposite.getInstance( java.awt.AlphaComposite.SRC_OVER, 0.5 );
                gfx.setComposite( ac );
                gfx.setPaint( java.awt.Color.white );
                gfx.fillRoundRect( border+1, h-py-size+1, progWidth, size-2, size, size );
            end
            
            % Update the on-screen image
            obj.Frame.repaint();
        end % updateProgressBar
        
    end % Private methods
    
end % classdef


%-------------------------------------------------------------------------%
function filename = iMakeFullName( filename )
% Absolute paths start with one of:
%   'X:' (Windows)
%   '\\' (UNC)
%   '/'  (Unix/Linux/Mac)
if ~strcmp(filename(2),':') ...
        && ~strcmp(filename(1:2),'\\') ...
        && ~strcmpi(filename(1),'/')
    % Relative path, so add current working directory
    filename = fullfile( pwd(), filename );
end
end % iMakeFullName


function [font,color,shadow] = parseFontArguments( varargin )
% Create a java font object based on some optional inputs
fontName = 'Arial';
fontSize = 12;
fontWeight = java.awt.Font.PLAIN;
fontAngle = 0;
color = java.awt.Color.red;
shadow = true;

if nargin
    params = varargin(1:2:end);
    values = varargin(2:2:end);
    if numel( params ) ~= numel( values )
        error( 'UIExtras:SplashScreen:BadSyntax', 'Optional arguments must be supplied as parameter-value pairs.' );
    end
    for ii=1:numel( params )
        switch upper( params{ii} )
            case 'FONTSIZE'
                fontSize = values{ii};
            case 'FONTNAME'
                fontName = values{ii};
            case 'FONTWEIGHT'
                switch upper( values{ii} )
                    case 'NORMAL'
                        fontWeight = java.awt.Font.PLAIN;
                    case 'BOLD'
                        fontWeight = java.awt.Font.PLAIN;
                    otherwise
                        error( 'UIExtras:SplashScreen:BadParameterValue', 'Unsupported FontWeight: %s.', values{ii} );
                end
            case 'FONTANGLE'
                switch upper( values{ii} )
                    case 'NORMAL'
                        fontAngle = 0;
                    case 'ITALIC'
                        fontAngle = java.awt.Font.ITALIC;
                    otherwise
                        error( 'UIExtras:SplashScreen:BadParameterValue', 'Unsupported FontAngle: %s.', values{ii} );
                end
            case 'COLOR'
                rgb = iInterpretColor( values{ii} );
                color = java.awt.Color( rgb(1), rgb(2), rgb(3) );
            case 'SHADOW'
                if ~ischar( values{ii} ) || ~ismember( upper( values{ii} ), {'ON','OFF'} )
                    error( 'UIExtras:SplashScreen:BadParameter', 'Option ''Shadow'' must be ''on'' or ''off''.' );                    
                end
                shadow = strcmpi( values{ii}, 'on' );
            otherwise
                error( 'UIExtras:SplashScreen:BadParameter', 'Unsupported optional parameter: %s.', params{ii} );
        end
    end
end
font = java.awt.Font( fontName, fontWeight+fontAngle, fontSize );
end % parseFontArguments


function col = iInterpretColor(str)
%interpretColor  Interpret a color as an RGB triple
%
%   rgb = uiextras.interpretColor(col) interprets the input color COL and
%   returns the equivalent RGB triple. COL can be one of:
%   * RGB triple of floating point numbers in the range 0 to 1
%   * RGB triple of UINT8 numbers in the range 0 to 255
%   * single character: 'r','g','b','m','y','c','k','w'
%   * string: one of 'red','green','blue','magenta','yellow','cyan','black'
%             'white'
%   * HTML-style string (e.g. '#FF23E0')
%
%   Examples:
%   >> uiextras.interpretColor( 'r' )
%   ans =
%        1   0   0
%   >> uiextras.interpretColor( 'cyan' )
%   ans =
%        0   1   1
%   >> uiextras.interpretColor( '#FF23E0' )
%   ans =
%        1.0000    0.1373    0.8784
%
%   See also: ColorSpec

%   Copyright 2005-2010 The MathWorks Ltd.
%   $Revision: 327 $
%   $Date: 2010-08-26 09:53:11 +0100 (Thu, 26 Aug 2010) $

if ischar( str )
    str = strtrim(str);
    str = dequote(str);
    if str(1)=='#'
        % HTML-style string
        if numel(str)==4
            col = [hex2dec( str(2) ), hex2dec( str(3) ), hex2dec( str(4) )]/15;
        elseif numel(str)==7
            col = [hex2dec( str(2:3) ), hex2dec( str(4:5) ), hex2dec( str(6:7) )]/255;
        else
            error( 'UIExtras:interpretColor:BadColor', 'Invalid HTML color %s', str );
        end
    elseif all( ismember( str, '1234567890.,; []' ) )
        % Try the '[0 0 1]' thing first
        col = str2num( str ); %#ok<ST2NM>
        if numel(col) == 3
            % Conversion worked, so just check for silly values
            col(col<0) = 0;
            col(col>1) = 1;
        end
    else
        % that didn't work, so try the name
        switch upper(str)
            case {'R','RED'}
                col = [1 0 0];
            case {'G','GREEN'}
                col = [0 1 0];
            case {'B','BLUE'}
                col = [0 0 1];
            case {'C','CYAN'}
                col = [0 1 1];
            case {'Y','YELLOW'}
                col = [1 1 0];
            case {'M','MAGENTA'}
                col = [1 0 1];
            case {'K','BLACK'}
                col = [0 0 0];
            case {'W','WHITE'}
                col = [1 1 1];
            case {'N','NONE'}
                col = [nan nan nan];
            otherwise
                % Failed
                error( 'UIExtras:interpretColor:BadColor', 'Could not interpret color %s', num2str( str ) );
        end
    end
elseif isfloat(str) || isdouble(str)
    % Floating point, so should be a triple in range 0 to 1
    if numel(str)==3
        col = double( str );
        col(col<0) = 0;
        col(col>1) = 1;
    else
        error( 'UIExtras:interpretColor:BadColor', 'Could not interpret color %s', num2str( str ) );
    end
elseif isa(str,'uint8')
    % UINT8, so range is implicit
    if numel(str)==3
        col = double( str )/255;
        col(col<0) = 0;
        col(col>1) = 1;
    else
        error( 'UIExtras:interpretColor:BadColor', 'Could not interpret color %s', num2str( str ) );
    end
else
    error( 'UIExtras:interpretColor:BadColor', 'Could not interpret color %s', num2str( str ) );
end
end % iInterpretColor

function str = dequote(str)
str(str=='''') = [];
str(str=='"') = [];
str(str=='[') = [];
str(str==']') = [];
end % dequote